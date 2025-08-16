return {
  -- catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        blink_cmp = { style = "bordered" },
        snacks = { enabled = true },
        mason = true,
        mini = { enabled = true },
        noice = true,
        notify = true,
        treesitter = true,
        treesitter_context = true,
      },
    },
  },
}
