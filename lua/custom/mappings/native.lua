local native_mappings = {
  i = {
    ["<A-j>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-k>"] = { "<cmd> m-- <CR>", "Move current line up" },
    ["<A-down>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-up>"] = { "<cmd> m-- <CR>", "Move current line up" },
  },

  n = {
    ["U"] = { "<C-r>", "redo" },
    ["<C-u>"] = { "<C-u>zz", "Go up half screen" },
    ["<C-d>"] = { "<C-d>zz", "Go down half screen" },

    ["<A-j>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-k>"] = { "<cmd> m-- <CR>", "Move current line up" },
    ["<A-down>"] = { "<cmd> m+ <CR>", "Move current line down" },
    ["<A-up>"] = { "<cmd> m-- <CR>", "Move current line up" },

    ["<leader><space>"] = { "<cmd> w <CR>", "Save file" },

    ["<leader>="] = { "<cmd> resize +5 <CR>", "Increase split height" }, -- (<leader>+)
    ["<leader>+"] = { "<cmd> resize +5 <CR>", "Increase split height" }, -- (<leader>+)
    ["<leader>-"] = { "<cmd> resize +5 <CR>", "Decrease split height" },
    ["<leader>>"] = { "<cmd> vertical resize +5 <CR>", "Increase split width" },
    ["<leader><"] = { "<cmd> vertical resize +5 <CR>", "Decrease split width" },

    ["<leader>tn"] = { "<cmd> set rnu! <CR>", "Toggle relative line numbers" },
    ["<leader>nb"] = { "<cmd> enew <CR>", "New buffer" },
    ["<leader>nt"] = { "<cmd> tabnew <CR>", "New tab" },

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
  },
}

return native_mappings
