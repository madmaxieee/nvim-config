-- ========================
-- disable folding for certain filetypes
-- ========================
local disabled_fts = {
  terminal = true,
  nvcheatsheet = true,
}

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("DisableFold", { clear = true }),
  callback = function()
    local ft = vim.bo.filetype
    if disabled_fts[ft] then
      vim.wo.foldcolumn = "0"
      vim.wo.foldenable = false
      vim.wo.foldmethod = "manual"
    end
  end,
})

-- ========================
-- Persistence
-- ========================
local persistenceGroup = vim.api.nvim_create_augroup("Persistence", { clear = true })
local home = vim.fn.expand "~"
local disabled_dirs = {
  [home] = true,
  [home .. "/Downloads"] = true,
  ["/private/tmp"] = true,
}

-- disable persistence for certain directories
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = persistenceGroup,
  callback = function()
    local cwd = vim.fn.getcwd()
    if vim.fn.argc() == 0 and not vim.g.started_with_stdin and not disabled_dirs[cwd] then
      require("persistence").load()
      require("nvim-tree.api").tree.toggle(false, true)
    else
      require("persistence").stop()
    end
  end,
  nested = true,
})

-- disable persistence if nvim started with stdin
vim.api.nvim_create_autocmd({ "StdinReadPre" }, {
  group = persistenceGroup,
  callback = function()
    vim.g.started_with_stdin = true
  end,
})

-- ========================
-- open help in vertical split
-- ========================
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("Help", { clear = true }),
  pattern = "help",
  callback = function()
    -- vim.cmd "wincmd L"
  end,
})
