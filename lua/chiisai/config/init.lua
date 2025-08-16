_G.Chiisai = require("chiisai.util")

---@class ChiisaiConfig: ChiisaiOptions
local M = {}
Chiisai.config = M

---@class ChiisaiOptions
local defaults = {
  ---@type string|fun()
  colorscheme = "catppuccin",
  defaults = {
    autocmds = true, -- chiisai.config.autocmds
    keymaps = true, -- chiisai.config.keymaps
  },
  icons = {
    diagnostics = {
      Error = " ",
      Warn = " ",
      Hint = " ",
      Info = " ",
    },
  },
}

---@type ChiisaiOptions
local options

---@param opts? ChiisaiOptions
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("Chiisai", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then
        M.load("autocmds")
      end
      M.load("keymaps")
    end,
  })

  Chiisai.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Chiisai.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod, required)
    if required then
      Chiisai.try(function()
        require(mod)
      end, "Failed loading " .. mod)
    else
      pcall(require, mod)
    end
  end

  if M.defaults[name] or name == "options" then
    _load("chiisai.config." .. name, true)
  end
  _load("config." .. name, false)
end

M.did_init = false
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true

  local plugin = require("lazy.core.config").spec.plugins.Chiisai
  if plugin then
    vim.opt.rtp:append(plugin.dir)
  end

  Chiisai.lazy_notify()
  M.load("options")
end

setmetatable(M, {
  __index = function(_, k)
    if options == nil then
      return vim.deepcopy(defaults)[k]
    end
    ---@cast options ChiisaiConfig
    return options[k]
  end,
})

return M
