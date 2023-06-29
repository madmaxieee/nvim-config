local mappings = {}

mappings.disabled = {
  n = {},
}

mappings.custom = {
  n = {
    ["<C-d>"] = { "<C-d>zz", "Go down half screen" },
    ["<C-u>"] = { "<C-u>zz", "Go up half screen" },
    ["<C-p>"] = { "<cmd> Telescope find_files <CR>", "Find files" },

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

    -- Copilot related mappings are managed by the plugin itself
    -- ["<A-l>"] = { "<cmd> Copilot suggestion accept <CR>", "Accept copilot suggestion" },
    -- ["<A-]>"] = { "<cmd> Copilot suggestion next <CR>", "Next copilot suggestion" },
    -- ["<A-[>"] = { "<cmd> Copilot suggestion prev <CR>", "Previous copilot suggestion" },
  },
}

return mappings
