local map = require("utils").safe_keymap_set

local success, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
if success then
  map({ "n", "x", "o" }, ";", function()
    ts_repeat_move.repeat_last_move()
    vim.cmd.normal { "zz", bang = true }
  end)
  map({ "n", "x", "o" }, ",", function()
    ts_repeat_move.repeat_last_move_opposite()
    vim.cmd.normal { "zz", bang = true }
  end)
end

map({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
map({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
map({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
map({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })

-- move line up and down
map("n", "<A-j>", "<cmd> m+ <CR>", { desc = "Move current line down" })
map("n", "<A-k>", "<cmd> m-- <CR>", { desc = "Move current line up" })
map("n", "<A-down>", "<cmd> m+ <CR>", { desc = "Move current line down" })
map("n", "<A-up>", "<cmd> m-- <CR>", { desc = "Move current line up" })

map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
map("v", "<A-down>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
map("v", "<A-up>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to down window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to up window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- misc
map("n", "<C-u>", "<C-u>zz", { desc = "Go up half screen" })
map("n", "<C-d>", "<C-d>zz", { desc = "Go down half screen" })

map("n", "<Esc>", "<cmd> noh <CR>", { desc = "Clear highlights" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "<leader><space>", "<cmd> update <CR>", { desc = "Save file" })

-- new tab and buffer
map("n", "<leader>tn", "<cmd> tabnew <CR>", { desc = "New tab" })
map("n", "<leader>tc", "<cmd> tabclose <CR>", { desc = "Close tab" })
map("n", "<leader>bn", "<cmd> vnew <CR>", { desc = "New buffer" })

-- Terminal mode
map("t", "<C-x>", vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), { desc = "Escape terminal mode" })

-- move the content in register to the system clipboard
map("n", "<leader>y", '"+y', { desc = "Copy to clipboard" })
map("v", "<leader>y", '"+y', { desc = "Copy to clipboard" })

-- comment
map("n", "<leader>/", "gcc", { desc = "Toggle comment line", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })

map({ "n", "x", "o" }, "gl", "$", { desc = "Move to end of line", silent = true })
map({ "n", "x", "o" }, "gh", "^", { desc = "Move to start of line", silent = true })

map("n", "X", ":.lua<CR>")
map("v", "X", ":lua<CR>")
