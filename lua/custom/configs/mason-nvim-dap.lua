local opts = {
  handlers = {
    function(config)
      require("mason-nvim-dap").default_setup(config)
    end,
    codelldb = function(config)
      require("mason-nvim-dap").default_setup(config)
    end,
  },
}

return opts
