local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "%#lualine_a_replace#" .. "Recording @" .. recording_register
  end
end

---@diagnostic disable-next-line: unused-local, unused-function
local function show_git_status()
  if not vim.b.gitsigns_head or vim.b.gitsigns_git_status then
    return ""
  end

  local git_status = vim.b.gitsigns_status_dict

  local added = (git_status.added and git_status.added ~= 0) and ("  " .. git_status.added) or ""
  local changed = (git_status.changed and git_status.changed ~= 0) and ("  " .. git_status.changed) or ""
  local removed = (git_status.removed and git_status.removed ~= 0) and ("  " .. git_status.removed) or ""
  local branch_name = "  " .. git_status.head

  return branch_name .. added .. changed .. removed
end

local function show_branch()
  if not vim.b.gitsigns_head or vim.b.gitsigns_git_status then
    return ""
  end

  local git_status = vim.b.gitsigns_status_dict

  return "  " .. git_status.head
end

local function show_lsp_status()
  for _, client in ipairs(vim.lsp.get_clients()) do
    if
      client.attached_buffers[vim.api.nvim_get_current_buf()]
      and client.name ~= "null-ls"
      and client.name ~= "typos_lsp"
    then
      return (vim.o.columns > 100 and "   LSP ~ " .. client.name) or "   LSP "
    end
  end
end

local function show_file_info()
  local icon = " 󰈚 "
  local path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local name = (path == "" and "Empty ") or path:match "([^/\\]+)[/\\]*$"
  if name:match ".*toggleterm.*" then
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

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "cbochs/grapple.nvim",
  },
  opts = {
    options = {
      disabled_filetypes = {
        statusline = {
          "dapui_scopes",
          "dapui_breakpoints",
          "dapui_stacks",
          "dapui_watches",
          "dapui_console",
          "dap-repl",
        },
      },
      globalstatus = false,
      section_separators = "",
      refresh = {
        statusline = 250,
        tabline = 1000,
        winbar = 1000,
      },
      component_separators = "▕%##",
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
        { "_branch", fmt = show_branch },
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
