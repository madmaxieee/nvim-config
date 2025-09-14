return {
  "NvChad/nvim-colorizer.lua",
  cmd = "ColorizerToggle",
  ft = {
    "html",
    "css",
    "scss",
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
  },
  opts = {
    user_default_options = {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = false,
      tailwind = true,
    },
  },
}
