local mappings = {}

mappings.disabled = {
  n = {
    ["<leader>td"] = "",
    ["<leader>n"] = "",
    ["<leader>rn"] = "",
    ["<leader>b"] = "",
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

    ["<leader>tn"] = { "<cmd> set rnu! <CR>", "Toggle relative line numbers" },
    ["<leader>nb"] = { "<cmd> enew <CR>", "New buffer" },

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

    ["<leader>gg"] = { "<cmd> LazyGit <CR>", "Invoke LazyGit" },
  },
}

mappings.dap = {
  plugin = true,
  n = {
    ["<leader>br"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle breakpoint at line" },
    ["<leader>db"] = {
      function()
        local dap = require "dap"
        local ft = vim.bo.filetype
        if ft == "" then
          print "Filetype option is required to determine which dap configs are available"
          return
        end
        local configs = dap.configurations[ft]
        if configs == nil then
          print('Filetype "' .. ft .. '" has no dap configs')
          return
        end

        -- always use the first config, assuming you only have one per filetype
        local iter = pairs(configs)
        local _, mConfig = iter(configs)

        -- redraw to make ui selector disappear
        vim.api.nvim_command "redraw"

        if mConfig == nil then
          return
        end
        vim.ui.input({
          prompt = mConfig.name .. " - with args: ",
        }, function(input)
          if input == nil then
            return
          end
          local args = vim.split(input, " ")
          mConfig.args = args
          dap.run(mConfig)
        end)
      end,
      "Start or continue the debugger",
    },
    ["<leader>dt"] = { "<cmd> DapTerminate <CR>", "Terminate the debugger" },
  },
}

return mappings
