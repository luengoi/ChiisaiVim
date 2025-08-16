local LazyUtil = require("lazy.core.util")

---@class chiisai.util: LazyUtilCore
---@field config ChiisaiConfig
---@field lsp chiisai.util.lsp
local M = {}

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then
      return LazyUtil[k]
    end
    t[k] = require("chiisai.util." .. k)
    return t[k]
  end,
})

--- Checks if neovim has been opened in a directory (instead of a file).
---@return boolean
function M.running_in_dir()
  local stats = vim.uv.fs_stat(vim.fn.argv(0))
  if stats and stats.type == "directory" then
    return true
  else
    return false
  end
end

--- Delay notifications till vim.notify was replaced or after 500ms
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig
    end
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  timer:start(500, 0, replay)
end

--- Wrapper around vim.keymap.set that will
--- not create a keymap if a lazy key handler exists.
--- It will also set `silent` to true by default.
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  local modes = type(mode) == "string" and { mode } or mode

  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs,m))
  end, modes)

  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap then
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

return M
