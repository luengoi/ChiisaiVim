require("chiisai.config").init()

return {
  { "folke/lazy.nvim", version = "*" },
  { "chiisai", priority = 10000, lazy = false, opts = {}, cond = true, version = "*", dev = true },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      notifier = { enabled = true },
      words = { enabled = true },
    },
    config = function(_, opts)
      local notify = vim.notify
      require("snacks").setup(opts)
      -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
      -- this is needed to have early notifications show up in noice history
      vim.notify = notify
    end,
  },
}
