local create_augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- don't some buffers in the buffer list
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

local no_lsp = {
  ["toggleterm"] = true,
  ["help"] = true,
}

autocmd("LspAttach", {
  group = disable_lsp_group,
  callback = function(args)
    local bufnr = args.buf
    local client_id = args.data.client_id
    if no_lsp[vim.bo[bufnr].filetype] or vim.wo.diff then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, client_id)
      end)
      vim.diagnostic.hide(nil, args.buf)
      vim.diagnostic.disable(args.buf)
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
