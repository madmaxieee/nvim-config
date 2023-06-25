local mappings = {}

mappings.abc = {
  n = {
    ["<C-d>"] = { "<C-d>zz", "go down half screen" },
    ["<C-u>"] = { "<C-u>zz", "go up half screen" },
  }
}

return mappings
