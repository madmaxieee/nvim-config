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

local function on_open(toggle_keymap)
  return function(term)
    map("n", "<C-c>", "<cmd>close<CR>", { buffer = term.bufnr, desc = "close toggleterm" })
    map("t", toggle_keymap, "<cmd>close<CR>", { buffer = term.bufnr, desc = "toggle term" })
    if vim.fn.mode() ~= "t" then
      vim.cmd "startinsert!"
    end
  end
end

local function create_terminal()
  local Terminal = require("toggleterm.terminal").Terminal
  return Terminal:new {
    cmd = vim.o.shell,
    direction = "float",
    hidden = true,
    float_opts = get_terminal_float_opts(),
    on_open = on_open "<A-i>",
  }
end

local function create_lazygit()
  local Terminal = require("toggleterm.terminal").Terminal
  return Terminal:new {
    cmd = "exec lazygit",
    direction = "float",
    hidden = true,
    float_opts = get_lazygit_float_opts(),
    on_open = on_open "<A-g>",
  }
end

return {
  "akinsho/toggleterm.nvim",
  keys = {
    {
      "<A-i>",
      mode = { "i", "n", "t" },
      function()
        if terminal then
          terminal:toggle()
        else
          terminal = create_terminal()
        end
      end,
      desc = "Toggle terminal",
    },
    {
      "<A-g>",
      mode = { "i", "n", "t" },
      function()
        if lazygit then
          lazygit:toggle()
        else
          lazygit = create_lazygit()
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
    terminal = create_terminal()
    lazygit = create_lazygit()
  end,
}
