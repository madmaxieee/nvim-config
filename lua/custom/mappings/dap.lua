local dap_mappings = {
  plugin = true,
  n = {
    ["<leader>br"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle breakpoint at line" },
    ["<leader>db"] = {
      function()
        local dap = require "dap"
        local ft = vim.bo.filetype
        if ft == "" then
          print "Filetype option is required to determine which dap configs are available"
          return
        end
        local configs = dap.configurations[ft]
        if configs == nil then
          print('Filetype "' .. ft .. '" has no dap configs')
          return
        end

        -- always use the first config, assuming you only have one per filetype
        local iter = pairs(configs)
        local _, mConfig = iter(configs)

        -- redraw to make ui selector disappear
        vim.api.nvim_command "redraw"

        if mConfig == nil then
          return
        end
        vim.ui.input({
          prompt = mConfig.name .. " - with args: ",
        }, function(input)
          if input == nil then
            return
          end
          local args = vim.split(input, " ")
          mConfig.args = args
          dap.run(mConfig)
        end)
      end,
      "Start debugger",
    },
    ["<leader>dt"] = { "<cmd> DapTerminate <CR>", "Terminate debugger" },
  },
}

return dap_mappings
