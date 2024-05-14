---@meta _
---@diagnostic disable

---@module 'SGG_Modding-ENVY'
local envy = rom.mods['SGG_Modding-ENVY']
---@module 'SGG_Modding-ENVY-auto'
envy.auto()

public.config = {}

function version_comparison(a,b)
	local ta, tb = type(a), type(b)
	if ta == 'number' and tb == 'number' then
		return b - a
	end
	if ta == 'number' then
		return 1
	end
	-- TODO: compare version strings
	return 0
end

function config.save(config_file_path,data)
    return pcall(rom.toml.encodeToFile, data, { file = config_file_path, overwrite = true })
end

function config.load(config_file_path,default)
    succeeded, data = pcall(rom.toml.decodeFromFile, config_file_path)
    if succeeded then
        return data
    end
    return default
end

function config.default_if_new_else_load(config_file_path,default,vercmp)
    local data = config.load(config_file_path,default)
	if data ~= default and default ~= nil and default.version ~= nil then
		vercmp = vercmp or version_comparison
		if data.version == nil or vercmp(data.version,default.version) > 0 then
			data = default
		end
	end
	return data
end

function config.save_if_new_else_load(config_file_path,default,vercmp)
    local data = config.default_if_new_else_load(config_file_path,default,vercmp)
	if data == default then
		config.save(config_file_path,default)
	end
	return data
end

function config.save_if_new_else_load_and_merge(config_file_path,default,vercmp)
    local data = config.default_if_new_else_load(config_file_path,default,vercmp)
	if data ~= default then
		for k,v in pairs(default) do
			if data[k] == nil then
				data[k] = v
			end
		end
	end
	config.save(config_file_path,data)
	return data
end

local default_config_name = 'config'

function public.update_lua_toml(env,config_lua,config_toml,vercmp)
	if config_toml == nil then
		if config_lua == nil then
			config_lua = default_config_name
		end
		config_toml = config_lua .. '.toml'
		config_lua = config_lua .. '.lua'
	end
	local default
	if env and env._PLUGIN then
		default = envy.import(env,config_lua)
		rom.path.create_directory(env._PLUGIN.config_mod_folder_path)
		config_lua = rom.path.combine(env._PLUGIN.plugins_mod_folder_path, config_lua)
		config_toml = rom.path.combine(env._PLUGIN.config_mod_folder_path, config_toml)
	else
		default = envy.import(rom.game,config_lua)
	end
	return config.save_if_new_else_load_and_merge(config_toml,default,vercmp)
end

function public.auto_lua_toml(config_lua,config_toml,vercmp)
	local env = envy.getfenv(2)
	return update_lua_toml(env,config_lua,config_toml,vercmp)
end