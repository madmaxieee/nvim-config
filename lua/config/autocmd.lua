local create_augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- don't include some buffers in the buffer list
autocmd("FileType", {
  pattern = { "qf", "oil" },
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- open help in vertical split
autocmd("FileType", {
  group = create_augroup("VerticalHelp", { clear = true }),
  pattern = "help",
  callback = function()
    vim.cmd "wincmd L"
  end,
})

-- disable lsp for certain filetypes and in diff mode
local disable_lsp_group = create_augroup("DisableLsp", { clear = true })

local no_lsp_filetype = {
  ["toggleterm"] = true,
  ["help"] = true,
}

local no_lsp_file_pattern = {
  [[/?%.env]],
}

local function detach_client(client_id, bufnr)
  vim.schedule(function()
    vim.lsp.buf_detach_client(bufnr, client_id)
  end)
  vim.diagnostic.hide(nil, bufnr)
  vim.diagnostic.enable(false, { bufnr = bufnr })
end

autocmd("LspAttach", {
  group = disable_lsp_group,
  callback = function(args)
    local bufnr = args.buf
    local client_id = args.data.client_id
    if no_lsp_filetype[vim.bo[bufnr].filetype] or vim.wo.diff then
      detach_client(client_id, bufnr)
      return
    end
    for _, pattern in ipairs(no_lsp_file_pattern) do
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename:match(pattern) then
        detach_client(client_id, bufnr)
        return
      end
    end
  end,
})

-- auto reload files when changed outside of neovim
autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  callback = function()
    vim.cmd "checktime"
  end,
})

autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
  end,
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*",
})
