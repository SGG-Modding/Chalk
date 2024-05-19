---@meta _
---@diagnostic disable

---@module 'SGG_Modding-ENVY'
local envy = rom.mods['SGG_Modding-ENVY']
---@module 'SGG_Modding-ENVY-auto'
envy.auto()

-- TODO: better array-like table handling (check ahead, pack into string, unpack from string)

local _wrap = setmetatable({},{__mode = 'v'})
local _orig = setmetatable({},{__mode = 'k'})
local _path = setmetatable({},{__mode = 'k'})

local default_config_lua = 'config.lua'

local flat = {
	string = true,
	number = true,
	boolean = true
}

local section_root = 'config'

local function find_pair(config,section,key)
    for k,v in pairs(config.entries) do
		if k.section == section and k.key == key then
			return k,v
		end
    end
end

local create_wrapper

local _meta = {
	__index = function(s,k)
		local _,e = find_pair(_orig[s],_path[s],k)
		if e == nil then
			return create_wrapper(s,k)
		else
			return e:get()
		end
	end,
	__newindex = function(s,k,v)
		local _,e = find_pair(_orig[s],_path[s],k)
		if e == nil then
			e:bind(_path[s],k,v)
		else
			e:set(v)
		end
	end,
	__pairs = function(s)
		local es = _orig[s].entries
		local p = _path[s]
		return function(_,k)
			while true do
				local d,e
				if k == nil then
					d,e = next(es)
				else
					d,e = next(es,p .. '.' .. k)
				end
				if d == nil then return end
				k = d.key
				if p == d.section then
					return k,e:get()
				end
			end
		end, s
	end,
	__ipairs = function(s)
		local es = _orig[s].entries
		local p = _path[s]
		return function(_,k)
			while true do
				local d,e
				if type(k) == 'number' then
					k = tostring(k)
				end
				if k == nil then
					d,e = next(es)
				else
					d,e = next(es,p .. '.' .. k)
				end
				if d == nil then return end
				k = d.key
				local i = tonumber(k)
				if i ~= nil and p == d.section then
					return i,e:get()
				end
			end
		end, s
	end
}

function create_wrapper(o,k)
	local w = setmetatable({},_meta)
	local path = _path[o] or section_root
	if k == nil then
		_wrap[o] = w
		_path[o] = path
	else
		path = path .. '.' .. k
	end
	_wrap[w] = w
	_path[w] = path
	_orig[w] = _orig[o] or o
	return w
end

function public.wrapper(o)
	local w = _wrap[o]
	if w ~= nil then return w end
	return create_wrapper(o)
end

function public.original(w)
	return _orig[w] or w
end

local function cmp_version(a,b)
	local ta, tb = type(a), type(b)
	if tb == 'string' then
		if ta ~= 'string' then return true end
		-- TODO: compare version strings
		return false
	end
	if tb == 'number' then
		if ta ~= 'number' then return true end
		return b > a
	end
	return false
end

local function get_version(obj)
	if type(obj) == 'userdata' then
		obj = public.wrapper(obj)
	end
	return obj.version
end

local function is_version_newer(a,b)
	local va, vb = get_version(a), get_version(b)
	return cmp_version(va,vb)
end

function public.load(path,default,descript,section,is_newer)
	local loaded
	do 
		local success, data = pcall(rom.toml.decodeFromFile, path)
		if success then
			loaded = select(2,next(data))
		end
	end
	local config = rom.config.config_file:new(path, true)
	if loaded ~= nil and default ~= nil then
		is_newer = is_newer or is_version_newer
		if is_newer(loaded,default) then
			return public.merge(config,default,descript,section)
		end
		public.merge(config,default,descript,section)
		return public.merge(config,loaded,descript,section)
	elseif loaded ~= nil then
		return public.merge(config,loaded,descript,section)
	elseif default ~= nil then
		return public.merge(config,default,descript,section)
	else
		return public.wrapper(config), config
	end
end

local function merge(k,v,config,default,descript,section)
	local _,c = find_pair(config,section,k)
	local t = type(v)
	local d = descript and descript[k]
	if flat[t] then
		if c == nil then
			c = config:bind(section,k,v,d or '')
		else
			c:set(v)
		end
	else
		public.merge(config,v,d,section .. '.' .. k)
	end
end

function public.merge(config,default,descript,section)
	config = public.original(config)
	section = section or section_root
	for i,v in ipairs(default) do
		local k = tostring(i)
		merge(k,v,config,default,descript,section)
	end
	for k,v in pairs(default) do
		if type(k) == 'string' then
			merge(k,v,config,default,descript,section)
		end
	end
	config:save()
	return public.wrapper(config), config
end

function public.replace(config,default,descript,section)
	config = public.original(config)
	local path = config.config_file_path
	pcall(os.remove,path)
	config = rom.config.config_file:new(path, true)
	public.merge(config,default,descript,section)
	return public.wrapper(config), config
end

function public.update(config,default,descript,section,is_newer)
	is_newer = is_newer or is_version_newer
	if is_newer(config,default) then
		return public.replace(config,default,descript,section)
	end
	return public.merge(config,default,descript,section)
end

function public.auto(config_lua,config_cfg,descript,section,is_newer)
	local env = envy.getfenv(2)
	if config_lua == nil then
		config_lua = default_config_lua
	end
	if env and env._PLUGIN then
		if config_cfg ~= nil then
			config_cfg = rom.path.combine(rom.paths.config(),env._PLUGIN.guid .. '-' .. config_cfg)
		else
			config_cfg = rom.path.combine(rom.paths.config(),env._PLUGIN.guid .. '.cfg')
		end
	else
		env = rom.game
	end
	local path,default,_descript,_section,_is_newer = envy.import(env,config_lua)
	descript = descript or _descript
	section = section or _section
	is_newer = is_newer or _is_newer
	return public.load(config_cfg,path,default,descript,section,is_newer)
end