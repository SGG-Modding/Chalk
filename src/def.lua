---@meta SGG_Modding-Chalk
local chalk = {}

chalk.config = {}

---@param path string path to config file to save the data to
---@param data table toml-compatible lua table to save to the file
---@return boolean success whether the file was able to be saved
---@return string? message the error message if the file failed to be saved
function chalk.config.save(path,data) end
---@alias SGG_Modding-Chalk.config.save ...

---@param path string path to config file to load the data from
---@param default table lua table to use if the file does not exist
---@return table data data loaded from the file, or otherwise `default`
function chalk.config.load(path,default) end
---@alias SGG_Modding-Chalk.config.load ...

---@param path string path to config file to load the data from
---@param default table lua table to use if newer than the file, or if the file does not exist
---@param vercmp? fun(a: any, b:any): sign: number C-style comparison function of the `version` field.
---@return table data data loaded from the file if it was not older, otherwise `default`
function chalk.config.default_if_new_else_load(path,default,vercmp) end
---@alias SGG_Modding-Chalk.config.default_if_new_else_load ...

---@param path string path to config file to load data from and save data to
---@param default table toml-compatible lua table to save if newer than the file, or if the file does not exist
---@param vercmp? fun(a: any, b:any): sign: number C-style comparison function of the `version` field.
---@return table data data loaded from the file if it was not older, otherwise `default`
function chalk.config.save_if_new_else_load(path,default,vercmp) end
---@alias SGG_Modding-Chalk.config.save_if_new_else_load ...

---@param path string path to config file to load data from and save data to
---@param default table toml-compatible lua table to merge into the data and save, if newer than the file, or if the file does not exist
---@param vercmp? fun(a: any, b:any): sign: number C-style comparison function of the `version` field.
---@return table data data loaded from the file if it was not older, otherwise the data merged with `default`
function chalk.config.save_if_new_else_load_and_merge(path,default,vercmp) end
---@alias SGG_Modding-Chalk.config.save_if_new_else_load_and_merge ...

--[[
          Loads and finds the more recent (by version) of the given plugin's `config.toml` and `config.lua`, and updates the `config.toml`.
]]
---@param env table? plugin's environment (or nil, but then the paths must be absolute)
---@param config_lua string name of (or path to) the config file to use as a default
---@param config_toml string name of (or path to) the config file to keep updated
---@param vercmp? fun(a: any, b:any): sign: number C-style comparison function of your config's `version` field.
---@return table data toml-compatible lua table with the updated config data
function chalk.update_lua_toml(env,config_lua,config_toml,vercmp) end
---@alias SGG_Modding-Chalk.update_lua_toml ...

--[[
          Loads and finds the more recent (by version) of *your plugin's* `config.toml` and `config.lua`, and updates the `config.toml`.
]]
---@param config_lua string name of (or path to) the config file to use as a default
---@param config_toml string name of (or path to) the config file to keep updated
---@param vercmp? fun(a: any, b:any): sign: number C-style comparison function of your config's `version` field.
---@return table data toml-compatible lua table with the updated config data
function chalk.auto_lua_toml(config_lua,config_toml,vercmp) end
---@alias SGG_Modding-Chalk.auto_lua_toml ...

return chalk