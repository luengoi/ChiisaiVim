return {
  -- LSP client configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile", "BufWritePre" },
    dependencies = {
      "mason-org/mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = Chiisai.config.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = Chiisai.config.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = Chiisai.config.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = Chiisai.config.icons.diagnostics.Info,
            },
          },
        },
        inlay_hints = {
          enabled = true,
          exclude = {},
        },
        codelens = {
          enabled = true,
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        servers = {},
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {
          -- you can do any additional lsp server setup here
          -- return true if you don't want this server to be setup with lspconfig
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      Chiisai.lsp.on_attach(function(client, buffer)
        require("chiisai.plugins.lsp.keymaps").on_attach(client, buffer)
      end)

      Chiisai.lsp.setup()
      Chiisai.lsp.on_dynamic_capability(require("chiisai.plugins.lsp.keymaps").on_attach)

      if opts.inlay_hints.enabled then
        Chiisai.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      if opts.codelens.enabled and vim.lsp.codelens then
        Chiisai.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local servers = opts.servers
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      local has_mlsp, mlsp = pcall(require, "mason-lspconfig")
      local all_mlsp_servers = {}
      if has_mlsp then
        all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
      end

      local function configure(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return true
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return true
          end
        end
        vim.lsp.config(server, server_opts)

        if server_opts.mason == false or not vim.tbl_contains(all_mlsp_servers, server) then
          vim.lsp.enable(server)
          return true
        end
        return false
      end

      local ensure_installed = {} ---@type string[]
      local exclude_automatic_enable = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            if configure(server) then
              exclude_automatic_enable[#exclude_automatic_enable + 1] = server
            else
              ensure_installed[#ensure_installed + 1] = server
            end
          else
            exclude_automatic_enable[#exclude_automatic_enable + 1] = server
          end
        end
      end

      if has_mlsp then
        mlsp.setup({
          ensure_installed = vim.tbl_deep_extend(
            "force",
            ensure_installed,
            Chiisai.opts("mason-lspconfig.nvim").ensure_installed or {}
          ),
          exclude = exclude_automatic_enable,
        })
      end
    end,
  },

  -- LSP server manager
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {},
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
