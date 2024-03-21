return {
  "williamboman/mason.nvim",
  build = "MasonInstallAll",
  cmd = {
    "Mason",
    "MasonInstall",
    "MasonInstallAll",
    "MasonUninstall",
    "MasonUninstallAll",
    "MasonLog",
  },
  opts = {
    ensure_installed = {
      "bash-language-server",
      "beautysh",
      "black",
      "clangd",
      "cmake-language-server",
      "codelldb",
      "css-lsp",
      "dockerfile-language-server",
      "eslint-lsp",
      "html-lsp",
      "isort",
      "json-lsp",
      "lua-language-server",
      "markdownlint",
      "nginx-language-server",
      "pyright",
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
    },

    PATH = "prepend",

    max_concurrent_installers = 10,
  },
  config = function(_, opts)
    require("mason").setup(opts)

    -- custom nvchad cmd to install all mason binaries listed
    vim.api.nvim_create_user_command("MasonInstallAll", function()
      vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
    end, {})

    vim.g.mason_binaries_list = opts.ensure_installed
  end,
}
