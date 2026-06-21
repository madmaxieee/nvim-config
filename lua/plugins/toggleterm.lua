return {
  {
    cond = not require("flags").is_minimal,
    "akinsho/toggleterm.nvim",
    opts = {
      float_opts = {
        border = "none",
      },
    },

    init = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local map = require("utils").safe_keymap_set

      ---@param term Terminal
      ---@param key string
      local function map_term_close(term, key)
        vim.api.nvim_buf_set_keymap(
          term.bufnr,
          "t",
          key,
          "<cmd>close<CR>",
          { noremap = true, silent = true }
        )
      end

      --- quick terminal
      local _TERM = Terminal:new({
        float_opts = { border = "single" },
        on_create = function(term)
          map_term_close(term, "<A-q>")
          map_term_close(term, "<A-i>")
        end,
      })

      map("n", "<A-q>", function()
        _TERM:toggle(nil, "float")
      end, { desc = "Toggle terminal" })
      map("n", "<A-i>", function()
        _TERM:toggle(nil, "float")
      end, { desc = "Toggle terminal" })

      --- lazyjj or lazygit
      local jj_utils = require("utils.jj")
      local lazy_command
      if jj_utils.find_root() then
        local jj_bin = vim.fn.exepath("jj")
        lazy_command = ("lazyjj --jj-bin %s --ignore-jj-version"):format(jj_bin)
      else
        lazy_command = "lazygit"
      end

      local _LAZYJJ_OR_GIT_TERM = Terminal:new({
        cmd = lazy_command,
        on_create = function(term)
          map_term_close(term, "<leader>j")
        end,
      })

      map("n", "<leader>j", function()
        _LAZYJJ_OR_GIT_TERM:toggle(nil, "float")
      end, { desc = "Toggle lazyjj or lazygit" })
    end,
  },
}
