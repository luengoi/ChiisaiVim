vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable autoformat-on-save
vim.g.disable_autoformat = false

-- Nvim options
vim.o.breakindent = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.list = true
vim.o.listchars = table.concat({ "tab:» ", "trail:·", "nbsp:␣" }, ",")
vim.o.number = true
vim.o.mouse = ""
vim.o.mousescroll = "ver:0,hor:0"
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.tabstop = 4
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.shiftwidth = 4
vim.o.showmode = false
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.scrolloff = 15
vim.o.wrap = false
