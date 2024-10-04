local commentstring_group = vim.api.nvim_create_augroup("Commentstring", { clear = true })

local commentstring_pattern_map = {
  ["*.dof"] = "// %s",
}

local set_commentstring = function(pattern, commentstring)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = commentstring_group,
    pattern = pattern,
    callback = function()
      vim.bo.commentstring = commentstring
    end,
  })
end

for pattern, string in pairs(commentstring_pattern_map) do
  set_commentstring(pattern, string)
end

local commentstring_filetype_map = {
  kdl = "// %s",
  kitty = "# %s",
  d2 = "# %s",
}

local set_commentstring_filetype = function(filetype, commentstring)
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = commentstring_group,
    pattern = filetype,
    callback = function()
      vim.bo.commentstring = commentstring
    end,
  })
end

for filetype, string in pairs(commentstring_filetype_map) do
  set_commentstring_filetype(filetype, string)
end

return {
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    keys = {
      { "gcc", mode = "n", desc = "Comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
      { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "Comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
      { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
      {
        "<leader>/",
        mode = "n",
        function()
          require("Comment.api").toggle.linewise.current()
        end,
        desc = "Toggle comment",
      },
      {
        "<leader>/",
        mode = "v",
        "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
        desc = "Toggle comment",
      },
    },
    config = function()
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("ts_context_commentstring").setup {
        enable_autocmd = false,
      }
    end,
  },
}
