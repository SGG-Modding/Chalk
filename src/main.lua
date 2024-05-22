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
local section_root = 'config'
local section_empty_key = '...'
local section_empty_value = ''
local section_empty_description = 'This is section is expandable, add more entries to flesh it out.'

local flat = {
	string = true,
	number = true,
	boolean = true
}

local function startswith(s, start)
    return s:sub(1, #start) == start
end

local function stringtail(s, start)
    return s:sub(#start+1)
end

local function pathstarts(path, start)
	start = start .. '.'
    return path:sub(1, #start) == start
end

local function pathtail(path, start)
    return path:sub(#start+1):sub(2)
end

local function pathnext(path, start)
	if not pathstarts(path, start) then return end
	local tail = pathtail(path, start)
	local foot = tail:find('%.')
	if foot == nil then return tail end
	return tail:sub(1,foot-1)
end

local function pathjoin(path, tail)
	return path .. '.' .. tail
end

local function findentry(config,section,key)
    for d,c in pairs(config.entries) do
		if d.section == section and d.key == key then
			return c
		end
    end
end

local function findchild(config,path)
	for d in pairs(config.entries) do
		local dp = pathjoin(d.section,d.key)
		local dk = pathnext(dp,path)
		if dk ~= nil then
			return dk
		end
    end
end

local function merge(k,v,config,descript,section,level)
	level = (level or 0) + 1
	if v == nil then
		error('cannot set a config entry to nil',level)
	end
	if k == nil then
		error('cannot set a config with nil key',level)
	end
	local c = findentry(config,section,k)
	local t = type(v)
	local d = descript and descript[k]
	if flat[t] then
		if c == nil then
			config:bind(section,k,v,d or '')
		else
			c:set(v)
		end
	else
		public.merge(config,v,d,section .. '.' .. k)
		local pk = pathjoin(section,k)
		if findchild(config,pk) == nil then
			config:bind(pk,section_empty_key,section_empty_value,section_empty_description)
		end
	end
end

local create_wrapper

local _meta = {
	__index = function(s,k)
		if k == section_empty_key then return nil end
		if type(k) == 'number' then
			k = tostring(k)
		end
		local o = _orig[s]
		local p = _path[s]
		local e = findentry(o,p,k)
		if e == nil then
			local pk = pathjoin(p,k)
			if findchild(_orig[s],pk) then 
				return create_wrapper(s,k)
			end
		else
			return e:get()
		end
		return nil
	end,
	__newindex = function(s,k,v)
		if k == section_empty_key then return end
		merge(k,v,_orig[s],nil,_path[s],2)
	end,
	__len = function(s)
		local es = _orig[s].entries
		local p = _path[s]
		local n = 0
		for d in pairs(es) do
			local dp = pathjoin(d.section,d.key)
			local dk = pathnext(dp,p)
			local i = tonumber(dk)
			if i ~= nil and i > n then n = i end
		end
		return n
	end,
	__next = function(s,k)
		-- TODO: improve this
		local es = {}
		local p = _path[s]
		for d,e in pairs(_orig[s].entries) do
			if d.key ~= section_empty_key then
				local dk = pathnext(pathjoin(d.section,d.key),p)
				if dk ~= nil then
					es[dk] = s[dk]
				end
			end
		end
		return next(es,k)
	end,
	__inext = function(s,i)
		if i == nil then i = 0 end
		if i < 0 or i >= #s then return end
		i = i + 1
		return i,s[i]
	end,
	__pairs = function(s)
		local es = {}
		local p = _path[s]
		for d,e in pairs(_orig[s].entries) do
			if d.key ~= section_empty_key then
				local dk = pathnext(pathjoin(d.section,d.key),p)
				if dk ~= nil then
					es[dk] = s[dk]
				end
			end
		end
		return pairs(es)
	end,
	__ipairs = function(s)
		local n = #s
		return function(_,i)
			if i == nil then i = 0 end
			if i < 0 or i >= n then return end
			i = i + 1
			return i,s[i]
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

function public.merge(config,default,descript,section)
	config = public.original(config)
	section = section or section_root
	for i,v in ipairs(default) do
		local k = tostring(i)
		merge(k,v,config,descript,section,2)
	end
	for k,v in pairs(default) do
		if type(k) == 'string' then
			merge(k,v,config,descript,section,2)
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