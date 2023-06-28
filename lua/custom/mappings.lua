local mappings = {}

mappings.disabled = {
  n = {},
}

mappings.custom = {
  n = {
    ["<C-d>"] = { "<C-d>zz", "Go down half screen" },
    ["<C-u>"] = { "<C-u>zz", "Go up half screen" },
    ["<C-p>"] = { "<cmd> Telescope find_files <CR>", "Find files" },

    -- ["<A-l>"] = { "<cmd> Copilot suggestion accept <CR>", "Accept copilot suggestion" },
    -- ["<A-]>"] = { "<cmd> Copilot suggestion next <CR>", "Next copilot suggestion" },
    -- ["<A-[>"] = { "<cmd> Copilot suggestion prev <CR>", "Previous copilot suggestion" },
  },
}

return mappings
