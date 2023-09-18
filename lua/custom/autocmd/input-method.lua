local input_method_group = vim.api.nvim_create_augroup("InputMethod", { clear = true })

local home = vim.fn.expand "~"

local function get_current_input_method()
  return (vim.fn.system {
    "defaults",
    "read",
    home .. "/Library/Preferences/com.apple.HIToolbox.plist",
    "AppleCurrentKeyboardLayoutInputSourceID",
  }):gsub("(%S+)%s*$", "%1")
end

local function next_input_method()
  -- have to enable control + option + space keyboard shortcut in system preferences
  vim.fn.system {
    "osascript",
    "-e",
    [[ tell application "System Events" to key code 49 using { option down, control down } ]],
  }
end

local function set_input_method(input_method)
  local seen = {}
  while get_current_input_method() ~= input_method do
    if seen[input_method] then
      vim.notify("Input method " .. input_method .. " not found", vim.log.levels.ERROR)
      return
    end
    next_input_method()
    seen[input_method] = true
  end
end

local function save_input_method()
  vim.g.input_method = get_current_input_method()
end

local function restore_input_method()
  if vim.g.input_method then
    set_input_method(vim.g.input_method)
  end
end

local function to_english()
  set_input_method "com.apple.keylayout.ABC"
end

if vim.fn.has "mac" then
  -- store original input method when entering vim and leaving insert mode, then switch to english
  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    group = input_method_group,
    callback = function()
      save_input_method()
      to_english()
    end,
  })

  vim.api.nvim_create_autocmd({ "FocusGained" }, {
    group = input_method_group,
    callback = function()
      if vim.fn.mode() ~= "i" then
        save_input_method()
        to_english()
      end
    end,
  })

  -- switch to english input method when exiting insert mode
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = input_method_group,
    callback = function()
      restore_input_method()
    end,
  })
end
