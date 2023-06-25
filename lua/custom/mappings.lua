local mappings = {}

mappings.disabled = {
  n = {
    -- ["C-n"] = "",
  }
}

mappings.custom = {
  n = {
    ["<C-d>"] = { "<C-d>zz", "go down half screen" },
    ["<C-u>"] = { "<C-u>zz", "go up half screen" },
    -- ["<C-n>"] = { "<cmd> NvimTreeToggle <CR>", "Toggle nvimtree" },
  }
}

return mappings
