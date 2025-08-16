local M = {}

---@param opts? ChiisaiConfig
function M.setup(opts)
  require("chiisai.config").setup(opts)
end

return M
