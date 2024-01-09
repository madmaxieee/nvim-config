local map = require("utils").safe_keymap_set
local float_window_config = require("utils").float_window_config

local terminal = nil
local lazygit = nil

local function get_terminal_float_opts()
  return float_window_config(0.8, 0.6, {})
end

local function get_lazygit_float_opts()
  return float_window_config(0.8, 0.8, {})
end

return {
  "akinsho/toggleterm.nvim",
  keys = {
    {
      "<A-i>",
      mode = "n",
      function()
        if terminal then
          terminal:toggle()
        end
      end,
      desc = "Toggle terminal",
    },
    {
      "<A-g>",
      mode = "n",
      function()
        if lazygit then
          lazygit:toggle()
        end
      end,
      desc = "Toggle lazygit",
    },
  },
  version = "*",
  init = function()
    vim.api.nvim_create_autocmd("VimResized", {
      group = vim.api.nvim_create_augroup("ToggleTermResize", { clear = true }),
      callback = function()
        if terminal then
          terminal.float_opts = get_terminal_float_opts()
        end
        if lazygit then
          lazygit.float_opts = get_lazygit_float_opts()
        end
      end,
    })
  end,
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local function on_open(term)
      map("t", "<C-c>", "<cmd>close<CR>", { buffer = term.bufnr })
      map("n", "<C-c>", "<cmd>close<CR>", { buffer = term.bufnr })
      map("t", "<A-i>", "<cmd>close<CR>", { buffer = term.bufnr })
      if vim.fn.mode() ~= "t" then
        vim.cmd "startinsert!"
      end
    end

    terminal = Terminal:new {
      cmd = vim.o.shell,
      direction = "float",
      hidden = true,
      float_opts = get_terminal_float_opts(),
      on_open = on_open,
    }
    lazygit = Terminal:new {
      cmd = "exec lazygit",
      direction = "float",
      hidden = true,
      float_opts = get_lazygit_float_opts(),
      on_open = on_open,
    }
  end,
}
