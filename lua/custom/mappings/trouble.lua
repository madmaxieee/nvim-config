local trouble_mapping = {
  n = {
    ["<leader>xx"] = {
      function()
        require("trouble").open()
      end,
      "open Trouble",
    },
    ["<leader>xw"] = {
      function()
        require("trouble").open "workspace_diagnostics"
      end,
      "open workspace diagnostics in Trouble",
    },
    ["<leader>xd"] = {
      function()
        require("trouble").open "document_diagnostics"
      end,
      "open document diagnostics in Trouble",
    },
    ["<leader>xq"] = {
      function()
        require("trouble").open "quickfix"
      end,
      "open in quickfix Trouble",
    },
    ["<leader>xl"] = {
      function()
        require("trouble").open "loclist"
      end,
      "open loclist in Trouble",
    },
    ["gR"] = {
      function()
        require("trouble").open "lsp_references"
      end,
      "open lsp references in Trouble",
    },
  },
}

return trouble_mapping
