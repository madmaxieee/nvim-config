local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "%#lualine_a_replace#" .. "Recording @" .. recording_register
  end
end

local function show_jj_log()
  return vim.b.jj_desc or ""
end

local function show_lsp_status()
  local copilot_icon
  if require("plugins.lsp.utils").lsp_should_enable("copilot") then
    copilot_icon = "   "
  else
    copilot_icon = "   "
  end
  for _, client in ipairs(vim.lsp.get_clients()) do
    if
      client.attached_buffers[vim.api.nvim_get_current_buf()]
      and client.name ~= "typos_lsp"
      and client.name ~= "harper_ls"
      and client.name ~= "copilot"
    then
      return (vim.o.columns > 100 and copilot_icon .. client.name)
        or copilot_icon
    end
  end
  return copilot_icon
end

local function show_file_info()
  local icon = " 󰈚 "
  local path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local name = (path == "" and "Empty ") or path:match("([^/\\]+)[/\\]*$")
  if name:match(".*toggleterm.*") then
    name = string.gsub(name, ";.*$", "")
    name = string.gsub(name, "^.*:", "")
  end

  if name ~= "Empty " then
    local ft_icon = require("nvim-web-devicons").get_icon(name)
    icon = (ft_icon ~= nil and " " .. ft_icon) or icon
    name = " " .. name
  end

  return icon .. name
end

---@type LazySpec
return {
  "madmaxieee/lualine.nvim",
  branch = "disable-statusline-option",
  -- "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "cbochs/grapple.nvim",
    {
      url = "https://tangled.org/bpavuk.neocities.org/jj-log.nvim",
      opts = {
        out_no_jj_repo = "",
        out_no_desc = "(no description set)",
      },
    },
  },
  opts = {
    options = {
      globalstatus = false,
      section_separators = "",
      refresh = {
        statusline = 250,
        tabline = 1000,
        winbar = 1000,
      },
      component_separators = "▕%##",
      disable_statusline = function(win_id)
        if vim.w[win_id].oil_preview or vim.w[win_id].is_oil_win then
          return true
        end
        return false
      end,
    },
    sections = {
      lualine_a = {
        "mode",
        { "macro-recording", fmt = show_macro_recording },
      },
      lualine_b = {
        "grapple",
        { "file-info", fmt = show_file_info },
      },
      lualine_c = {
        { "jj_log", fmt = show_jj_log },
        "diff",
        "diagnostics",
      },
      lualine_x = {
        { "lsp-status", fmt = show_lsp_status },
        "filetype",
      },
      lualine_y = {
        "progress",
      },
      lualine_z = {
        "location",
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {
        { "file-info", fmt = show_file_info },
      },
      lualine_c = { "diagnostics" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
