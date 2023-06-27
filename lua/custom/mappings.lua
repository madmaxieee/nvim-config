local mappings = {}

mappings.disabled = {
  n = {},
}

mappings.custom = {
  n = {
    ["<C-d>"] = { "<C-d>zz", "go down half screen" },
    ["<C-u>"] = { "<C-u>zz", "go up half screen" },
    ["<C-p>"] = { "<cmd> Telescope find_files <CR>", "Find files" },

    ["<leader>cp"] = { "<cmd> Copilot panel open <CR>", "Open copilot panel" },
  },
}

return mappings
