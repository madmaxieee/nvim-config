local function should_ask()
  return vim.fn.expand "$USER" == "maxcchuang"
end

local function confirm_use_copilot()
  local choice = vim.fn.confirm("enable copilot?", "&yes\n&no", 2)
  if choice == 1 then
    return true
  else
    return false
  end
end

local function load_copilot()
  vim.api.nvim_exec_autocmds("User", { pattern = "LoadCopilot" })
end

return {
  "zbirenbaum/copilot.lua",
  event = "User LoadCopilot",

  init = function()
    vim.api.nvim_create_autocmd("SessionLoadPost", {
      once = true,
      callback = function()
        if vim.g.EnableCopilot ~= 1 then
          vim.g.EnableCopilot = nil
          return
        end
        if should_ask() then
          vim.defer_fn(function()
            local enable = confirm_use_copilot()
            if enable then
              vim.g.EnableCopilot = 1
              load_copilot()
            else
              vim.g.EnableCopilot = nil
            end
          end, 300)
        else
          load_copilot()
        end
      end,
    })

    vim.api.nvim_create_user_command("CopilotEnable", function()
      vim.g.EnableCopilot = 1
      if vim.g.loaded_copilot then
        vim.cmd "Copilot enable"
      else
        load_copilot()
      end
      vim.notify "Copilot enabled"
    end, {})

    vim.api.nvim_create_user_command("CopilotDisable", function()
      vim.g.EnableCopilot = nil
      if vim.g.loaded_copilot then
        vim.cmd "Copilot disable"
      end
      vim.notify "Copilot disabled"
    end, {})
  end,

  config = function()
    require("copilot").setup {
      panel = {
        enabled = false,
        auto_refresh = false,
        layout = {
          position = "bottom", -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<A-l>",
          accept_word = false,
          accept_line = false,
          next = "<A-]>",
          prev = "<A-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        help = false,
        gitrebase = false,
        ["*"] = true,
      },
    }
    vim.g.loaded_copilot = true
  end,
}
