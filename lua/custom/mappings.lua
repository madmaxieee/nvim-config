local mappings = {}

mappings.disabled = {
  n = {},
}

mappings.custom = {
  i = {
    ["<A-j>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-k>"] = { "<cmd> m-- <CR>", "Move current line up" },
    ["<A-down>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-up>"] = { "<cmd> m-- <CR>", "Move current line up" },
  },

  n = {
    ["<A-j>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-k>"] = { "<cmd> m-- <CR>", "Move current line up" },
    ["<A-down>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-up>"] = { "<cmd> m-- <CR>", "Move current line up" },
    ["<leader>s"] = { "<cmd> wa <CR>", "Save all buffers" },

    ["<C-u>"] = { "<C-u>zz", "Go up half screen" },
    ["<C-d>"] = { "<C-d>zz", "Go down half screen" },

    ["<C-p>"] = { "<cmd> Telescope find_files <CR>", "Find files" },
    ["<leader>fs"] = { "<cmd> Telescope lsp_document_symbols <CR>", "Search document symbols" },
    ["<leader>y"] = { "<cmd> Telescope neoclip <CR>", "Search clipboard history" },

    ["gx"] = {
      function()
        -- the original gx functionality is provided by netrw, which is hijacked by nvim-tree
        if vim.fn.has "mac" == 1 then
          vim.cmd [[call jobstart(["open", expand("<cfile>")], {"detach": v:true})]]
        elseif vim.fn.has "unix" == 1 then
          vim.cmd [[call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})]]
        end
      end,
      "Open URL or file",
    },

    ["<leader>tc"] = {
      function()
        if vim.o.colorcolumn == "" then
          vim.opt.colorcolumn = "80"
        else
          vim.opt.colorcolumn = ""
        end
      end,
      "Toggle colorcolumn",
    },

    -- Copilot related mappings are managed by the plugin itself
    -- ["<A-l>"] = { "<cmd> Copilot suggestion accept <CR>", "Accept copilot suggestion" },
    -- ["<A-]>"] = { "<cmd> Copilot suggestion next <CR>", "Next copilot suggestion" },
    -- ["<A-[>"] = { "<cmd> Copilot suggestion prev <CR>", "Previous copilot suggestion" },
  },
}

return mappings
