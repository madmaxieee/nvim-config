local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "%#lualine_a_replace#" .. "Recording @" .. recording_register
  end
end

return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      globalstatus = true,
      section_separators = " ",
      refresh = {
        statusline = 250,
        tabline = 1000,
        winbar = 1000,
      },
      component_separators = "▕",
    },
    sections = {
      lualine_a = {
        "mode",
        {
          "macro-recording",
          fmt = show_macro_recording,
        },
      },
      lualine_b = {
        "branch",
        -- "diff",
        "diagnostics",
      },
      lualine_c = { "filename" },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
