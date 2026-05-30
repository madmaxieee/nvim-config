return {
  url = "https://tangled.org/ronshavit.com/jjannotate.nvim",
  init = function()
    vim.api.nvim_create_user_command("JJAnnotate", function()
      local path = vim.api.nvim_buf_get_name(0)
      path = vim.fs.abspath(path)
      require("jjannotate").open(path)
    end, {})
  end,
}
