local ensure_installed = {
  "bash-language-server",
  "beautysh",
  "black",
  "checkstyle",
  "clangd",
  "cmake-language-server",
  "codelldb",
  "css-lsp",
  "dockerfile-language-server",
  "eslint-lsp",
  "gopls",
  "html-lsp",
  "isort",
  "jdtls",
  "json-lsp",
  "lua-language-server",
  "markdownlint",
  "nil",
  "nginx-language-server",
  "pyright",
  "pylint",
  "rust-analyzer",
  "stylua",
  "svelte-language-server",
  "taplo",
  "tailwindcss-language-server",
  "typescript-language-server",
  "typos-lsp",
  "typst-lsp",
  "yaml-language-server",
  "xmlformatter",
  "zls",
}

vim.api.nvim_create_user_command("MasonInstallAll", function()
  vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
end, {})

return {
  "williamboman/mason.nvim",
  build = function(_)
    vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
  end,
  cmd = {
    "Mason",
    "MasonInstall",
    "MasonInstallAll",
    "MasonUninstall",
    "MasonUninstallAll",
    "MasonLog",
  },
  opts = {
    PATH = "prepend",
    max_concurrent_installers = 10,
  },
  config = function(_, opts)
    require("mason").setup(opts)
  end,
}
