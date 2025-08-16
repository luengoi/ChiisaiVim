local map = Chiisai.safe_keymap_set

-- Clear search highlights
map("n", "<esc>", "<cmd>noh<cr>", { desc = "Clear search highlights" })

-- Diagnostics quickfix list
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [q]uickfix list" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment above" })
