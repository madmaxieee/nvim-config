vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("NoTerminalFold", { clear = true }),
  callback = function()
    if vim.bo.filetype == "terminal" then
      vim.wo.foldcolumn = "0"
    end
  end,
})

local persistenceGroup = vim.api.nvim_create_augroup("Persistence", { clear = true })
local home = vim.fn.expand "~"
local disabled_dirs = {
  home,
  home .. "/Downloads",
  "/private/tmp",
}

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = persistenceGroup,
  callback = function()
    local cwd = vim.fn.getcwd()
    for _, path in pairs(disabled_dirs) do
      if path == cwd then
        require("persistence").stop()
        return
      end
    end

    if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
      require("persistence").load()
      require("nvim-tree.api").tree.toggle(false, true)
    else
      require("persistence").stop()
    end
  end,
  nested = true,
})

vim.api.nvim_create_autocmd({ "StdinReadPre" }, {
  group = persistenceGroup,
  callback = function()
    vim.g.started_with_stdin = true
  end,
})
