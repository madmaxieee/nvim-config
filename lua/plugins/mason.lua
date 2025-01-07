local ensure_installed = {
  "bash-language-server",
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
  "nginx-language-server",
  "pyright",
  "ruff",
  "rust-analyzer",
  "shellcheck",
  "shfmt",
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

return {
  "williamboman/mason.nvim",
  init = function(_)
    vim.api.nvim_create_user_command("MasonInstallAll", function()
      vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
    end, {})
  end,
  build = function(_)
    vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
  end,
  cmd = {
    "Mason",
    "MasonInstall",
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
