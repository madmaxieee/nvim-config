local mappings = {}

mappings.disabled = {
  n = {
    "<leader>td",
  },
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

    ["<leader><space>"] = { "<cmd> w <CR>", "Save file" },

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

    ["zR"] = {
      function()
        require("ufo").openAllFolds()
      end,
      "Open all folds",
    },
    ["zM"] = {
      function()
        require("ufo").closeAllFolds()
      end,
    },

    ["<leader>gd"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle git deleted",
    },

    ["<leader>td"] = { "<cmd> TodoTrouble <CR>", "Open todos panel" },
    ["<leader>ft"] = { "<cmd> TodoTelescope <CR>", "Open todos panel" },

    -- (<leader>+)
    ["<leader>="] = { "3<C-w>>", "Increase split width" },
    ["<leader>-"] = { "3<C-w><", "Decrease split width" },
  },
}

return mappings
