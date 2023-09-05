local mappings = {}

mappings.disabled = require "custom.mappings.disabled"

mappings.native = require "custom.mappings.native"

mappings.dap = require "custom.mappings.dap"

mappings.trouble = require "custom.mappings.trouble"

mappings.gitsigns = {
  n = {
    ["<leader>gd"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle git deleted",
    },
  },
}

mappings.telescope = {
  n = {
    ["<C-p>"] = { "<cmd> Telescope find_files <CR>", "Find files" },
    ["<leader>fs"] = { "<cmd> Telescope lsp_document_symbols <CR>", "Search document symbols" },
    ["<leader>y"] = { "<cmd> Telescope neoclip <CR>", "Search clipboard history" },
  },
}

mappings.ufo = {
  plugin = true,
  n = {
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
      "Close all folds",
    },
  },
}

mappings["Todo Comments"] = {
  plugin = true,
  n = {
    ["<leader>td"] = { "<cmd> TodoTrouble <CR>", "Open todos panel" },
    ["<leader>ft"] = { "<cmd> TodoTelescope <CR>", "Open todos panel" },
  },
}

mappings.LazyGit = {
  plugin = true,
  n = {
    ["<leader>lg"] = { "<cmd> LazyGit <CR>", "Invoke LazyGit" },
  },
}

mappings.persistence = {
  plugin = true,
  n = {
    ["<leader>ps"] = {
      function()
        require("persistence").stop()
      end,
      "Stop persistence from saving the session",
    },
    ["<leader>pl"] = {
      function()
        require("persistence").load()
      end,
      "Load last saved session for current directory",
    },
  },
}

mappings.Hardtime = {
  plugin = true,
  n = {
    ["<leader>ht"] = {
      function()
        require("hardtime").toggle()
      end,
      "Toggle hardtime",
    },
  },
}

return mappings
