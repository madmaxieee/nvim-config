return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  opts = {
    ensure_installed = {},
    registries = {
      "github:mason-org/mason-registry",
      -- "github:madmaxieee/mason-registry",
    },
  },
  opts_extend = { "ensure_installed" },
  config = function(_, opts)
    local registry = require "mason-registry"
    local ensure_installed = opts.ensure_installed or {}
    opts.ensure_installed = nil
    require("mason").setup(opts)
    vim.schedule(function()
      for _, name in ipairs(ensure_installed) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and pkg and not pkg:is_installed() then
          pkg:install {}
        end
      end
    end)
  end,
}
