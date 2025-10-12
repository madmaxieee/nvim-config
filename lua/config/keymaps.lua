local map = require("utils").safe_keymap_set

local repeatable = require "repeatable"

map({ "n", "x", "o" }, ";", function()
  repeatable.repeat_last_move()
end)
map({ "n", "x", "o" }, ",", function()
  repeatable.repeat_last_move_opposite()
end)

map({ "n", "x", "o" }, "f", repeatable.builtin_f_expr, { expr = true })
map({ "n", "x", "o" }, "F", repeatable.builtin_F_expr, { expr = true })
map({ "n", "x", "o" }, "t", repeatable.builtin_t_expr, { expr = true })
map({ "n", "x", "o" }, "T", repeatable.builtin_T_expr, { expr = true })

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

-- new tab and buffer
map("n", "<leader>tn", "<cmd> tabnew <CR>", { desc = "New tab" })
map("n", "<leader>tc", "<cmd> tabclose <CR>", { desc = "Close tab" })
map("n", "<leader>bn", "<cmd> vnew <CR>", { desc = "New buffer" })

-- Terminal mode
map("t", "<C-x>", vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), { desc = "Escape terminal mode" })

-- move the content in register to the system clipboard
map("n", "<leader>y", '"+y', { desc = "Copy to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Copy to clipboard" })
map("v", "<leader>y", '"+y', { desc = "Copy to clipboard" })

-- comment
map("n", "<leader>/", "gcc", { desc = "Toggle comment line", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })
map("n", "gC", "gcic", { desc = "Uncomment commented lines", remap = true })
map("o", "ic", require("vim._comment").textobject, { desc = "Select commented lines" })
map("x", "ic", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, true, true), "nx", false)
  require("vim._comment").textobject()
end, { desc = "Select commented lines" })

-- misc
map("n", "<C-u>", "<C-u>zz", { desc = "Go up half screen" })
map("n", "<C-d>", "<C-d>zz", { desc = "Go down half screen" })

map("n", "<Esc>", "<cmd> noh <CR>", { desc = "Clear highlights" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "<leader><space>", "<cmd> update <CR>", { desc = "Save file" })

map({ "n", "x", "o" }, "gl", "$", { desc = "Move to end of line", silent = true })
map({ "n", "x", "o" }, "gh", "^", { desc = "Move to start of line", silent = true })

map("n", "X", ":.lua<CR>", { desc = "Execute current line" })
map("v", "X", ":lua<CR>", { desc = "Execute selected code" })

map({ "n", "v" }, "<leader>rn", function()
  vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative number" })

-- avoid "q:" typo
map("c", "<C-f>", function()
  vim.g.requested_cmdwin = true
  return "<C-f>"
end, { expr = true })

vim.api.nvim_create_autocmd("CmdwinEnter", {
  group = vim.api.nvim_create_augroup("QuitCmdWin", { clear = true }),
  callback = function()
    if not vim.g.requested_cmdwin then
      vim.cmd "q"
      vim.api.nvim_input(vim.fn.getcmdwintype() .. "q")
    end
    vim.g.requested_cmdwin = nil
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
