return {
  "williamboman/mason.nvim",
  opts = { ensure_installed = {} },
  opts_extend = { "ensure_installed" },
  config = function(_, opts)
    local registry = require "mason-registry"
    local ensure_installed = opts.ensure_installed or {}
    opts.ensure_installed = nil
    require("mason").setup(opts)
    for _, name in ipairs(ensure_installed) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok then
        pkg:install {}
      end
    end
  end,
}
