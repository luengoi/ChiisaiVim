return {
  -- completion
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      signature = { enabled = true },
    },
  },

  -- formatting
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "[F]ormat buffer",
      },
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
}
