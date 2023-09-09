local trouble_mapping = {
  plugin = true,
  n = {
    ["<leader>tt"] = {
      function()
        require("trouble").open()
      end,
      "open Trouble",
    },
    ["<leader>tw"] = {
      function()
        require("trouble").open "workspace_diagnostics"
      end,
      "open workspace diagnostics in Trouble",
    },
    ["<leader>tq"] = {
      function()
        require("trouble").open "quickfix"
      end,
      "open in quickfix Trouble",
    },
    -- ["<leader>xl"] = {
    --   function()
    --     require("trouble").open "loclist"
    --   end,
    --   "open loclist in Trouble",
    -- },
    ["gR"] = {
      function()
        require("trouble").open "lsp_references"
      end,
      "open lsp references in Trouble",
    },
  },
}

return trouble_mapping
