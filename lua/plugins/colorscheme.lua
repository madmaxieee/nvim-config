local kv = require("kv")

vim.api.nvim_create_user_command("ColorschemeDark", function()
  kv.set("theme", "dark")
end, {})
vim.api.nvim_create_user_command("ColorschemeLight", function()
  kv.set("theme", "light")
end, {})

---@param conf Kv?
local function maybe_set_colorscheme(conf)
  if not conf then
    conf = kv.get()
  end
  if not conf then
    return
  end
  local target_colorscheme
  if conf.theme == "dark" then
    vim.opt.background = "dark"
    target_colorscheme = conf.colorscheme
  elseif conf.theme == "light" then
    vim.opt.background = "light"
    target_colorscheme = conf.colorscheme_light
  else
    return
  end
  if vim.g.colors_name ~= target_colorscheme then
    pcall(vim.cmd.colorscheme, target_colorscheme)
  end
end

kv.on_change({ "theme", "colorscheme", "colorscheme_light" }, function(conf)
  maybe_set_colorscheme(conf)
end)

local is_set = false
local function startup_colorscheme()
  if is_set then
    return
  end
  is_set = true
  maybe_set_colorscheme()
end

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      startup_colorscheme()
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      startup_colorscheme()
    end,
  },
}
