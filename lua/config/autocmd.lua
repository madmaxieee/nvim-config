vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("VerticalHelp", { clear = true }),
  pattern = "help",
  callback = function()
    vim.cmd "wincmd L"
  end,
})

local disable_lsp_group = vim.api.nvim_create_augroup("DisableLsp", { clear = true })

local no_lsp = {
  ["toggleterm"] = true,
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = disable_lsp_group,
  callback = function(args)
    local bufnr = args.buf
    local client_id = args.data.client_id
    if no_lsp[vim.bo[bufnr].filetype] then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, client_id)
      end)
      vim.diagnostic.hide(nil, args.buf)
      vim.diagnostic.disable(args.buf)
    end
  end,
})
