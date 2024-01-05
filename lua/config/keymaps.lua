local map = require("utils").safe_keymap_set

-- Insert mode
map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })

-- Normal mode
map("n", "<A-j>", "<cmd> m+ <CR>", { desc = "Move current line down" })
map("n", "<A-k>", "<cmd> m-- <CR>", { desc = "Move current line up" })
map("n", "<A-down>", "<cmd> m+ <CR>", { desc = "Move current line down" })
map("n", "<A-up>", "<cmd> m-- <CR>", { desc = "Move current line up" })

map("n", "<C-h>", "<cmd> wincmd h <CR>", { desc = "Go to left window" })
map("n", "<C-j>", "<cmd> wincmd j <CR>", { desc = "Go to down window" })
map("n", "<C-k>", "<cmd> wincmd k <CR>", { desc = "Go to up window" })
map("n", "<C-l>", "<cmd> wincmd l <CR>", { desc = "Go to right window" })

map("n", "<C-u>", "<C-u>zz", { desc = "Go up half screen" })
map("n", "<C-d>", "<C-d>zz", { desc = "Go down half screen" })

map("n", "<Esc>", "<cmd> noh <CR>", { desc = "Clear highlights" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "<leader><space>", "<cmd> update <CR>", { desc = "Save file" })

map("n", "<leader>fm", function()
  vim.lsp.buf.format { async = true }
end, { desc = "LSP formatting" })

-- Visual mode
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
map("v", "<A-down>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
map("v", "<A-up>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- Terminal mode
map("t", "<C-x>", vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), { desc = "Escape terminal mode" })
