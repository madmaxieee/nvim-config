vim.g.has_google = vim.fn.isdirectory "/google" == 1
if not vim.g.has_google then
  return {}
end

local utils = require "utils"

utils.on_load("nvim-lspconfig", function()
  -- http://cl/783896564
  vim.lsp.config("ciderlsp", {
    cmd = {
      "/google/bin/releases/cider/ciderlsp/ciderlsp",
      "--tooltag=nvim-lsp",
      "--noforward_sync_responses",
      "--cdpush_name=",
    },
    filetypes = {
      "borg",
      "bzl",
      "c",
      "cpp",
      "cs",
      "dart",
      "gcl",
      "go",
      "googlesql",
      "graphql",
      "java",
      "kotlin",
      "markdown",
      "mlir",
      "ncl",
      "objc",
      "patchpanel",
      "proto",
      "python",
      "qflow",
      "soy",
      "swift",
      "textpb",
      "typescript",
    },
    root_dir = function(bufnr, cb)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root_dir = string.match(fname, "(/google/src/cloud/[%w_-]+/[%w_-]+/).+$")
      if root_dir then
        cb(root_dir)
      end
    end,
  })
  vim.lsp.enable "ciderlsp"
end)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ciderlsp.attach", { clear = true }),
  callback = function(args)
    local ciderlsp_client = vim.lsp.get_client_by_id(args.data.client_id)
    if ciderlsp_client and ciderlsp_client.name == "ciderlsp" then
      -- disable lsps for languages ciderlsp supports
      for _, name in ipairs {
        "clangd",
        "copilot",
        "eslint",
        "gopls",
        "jdtls",
        "pyright",
        "ruff",
        "ts_ls",
      } do
        vim.cmd("LspStop " .. name)
      end
    end
  end,
})

return {
  {
    import = "plugins.google",
  },
}
