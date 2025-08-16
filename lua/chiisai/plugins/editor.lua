function _G.chiisai_oil_winbar()
  -- Show CWD in winbar
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    return vim.api.nvim_buf_get_name(0)
  end
end

return {
  -- directory management
  {
    "stevearc/oil.nvim",
    keys = {
      { "<leader>o", "<cmd>Oil<cr>", desc = "Open parent directory in Oil" },
    },
    lazy = (function()
      local stats = vim.uv.fs_stat(vim.fn.argv(0))
      if stats and stats.type == "directory" then
        return false
      else
        return true
      end
    end)(),
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
      win_options = {
        winbar = "%!v:lua.chiisai_oil_winbar()",
      },
    },
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- this plugin does not support lazy loading
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-context", main = "treesitter-context" },
    },
    keys = {
      -- jump to context (upwards)
      {
        "n",
        "[c",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        { silent = true },
      },
    },
    opts_extend = { "ensure_installed" },
    ---@type TSConfig
    opts = {
      ensure_installed = {
        "query",
        "vim",
        "vimdoc",
      },
      auto_install = false,
    },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")
      treesitter.setup(opts)
      treesitter.install(opts.ensure_installed or {})
    end,
  },

  -- better text-objects
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    opts = {
      n_lines = 500,
    },
  },

  -- better surroundings
  {
    "echasnovski/mini.surround",
    version = false,
    event = "VeryLazy",
  },

  -- git integration
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
      end,
    },
  },
}
