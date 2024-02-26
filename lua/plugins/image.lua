return {
  "3rd/image.nvim",
  ft = { "markdown" },
  config = function()
    require("image").setup {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = true,
          filetypes = { "markdown" },
        },
      },
      editor_only_render_when_focused = false,
    }
  end,
}
