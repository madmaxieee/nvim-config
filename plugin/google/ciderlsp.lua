if not require("flags").in_google3 then
  return
end

local _CIDERLSP_UNSUPPORTED_CAPABILITIES_BY_FILE_TYPE = {
  bzl = {
    "documentHighlightProvider",
    "inlayHintProvider",
  },
  gcl = {
    "documentHighlightProvider",
    "inlayHintProvider",
  },
  markdown = {
    "documentHighlightProvider",
    "inlayHintProvider",
  },
  proto = {
    "documentHighlightProvider",
    "inlayHintProvider",
  },
  typescript = {
    "documentHighlightProvider",
  },
}

local _LSP_SHOULD_DISABLE_WITH_CIDERLSP = {
  "clangd",
  "copilot",
  "eslint",
  "gopls",
  "jdtls",
  "pyrefly",
  "ruff",
  "ts_ls",
}

require("utils.lazy").on_load("nvim-lspconfig", function()
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
      "pbtext",
      "proto",
      "python",
      "qflow",
      "soy",
      "swift",
      "typescript",
    },
    root_dir = function(bufnr, cb)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root_dir =
        string.match(fname, "(/google/src/cloud/[%w_-]+/[%w_-]+/).+$")
      if root_dir then
        cb(root_dir)
      end
    end,
  })
  vim.lsp.enable("ciderlsp")

  local ciderlsp_attach_once_group =
    vim.api.nvim_create_augroup("ciderlsp.attach.once", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = ciderlsp_attach_once_group,
    callback = function(args)
      local ciderlsp_client = vim.lsp.get_client_by_id(args.data.client_id)
      if not (ciderlsp_client and ciderlsp_client.name == "ciderlsp") then
        return
      end

      -- ciderlsp does not support some methods on certain languages
      local ft = vim.bo[args.buf].filetype
      for _, capability in
        ipairs(_CIDERLSP_UNSUPPORTED_CAPABILITIES_BY_FILE_TYPE[ft] or {})
      do
        ciderlsp_client.server_capabilities[capability] = nil
      end

      -- disable lsps for languages ciderlsp supports
      for _, name in ipairs(_LSP_SHOULD_DISABLE_WITH_CIDERLSP) do
        vim.cmd("lsp disable " .. name)
      end

      -- Fixes ciderlsp's rename behavior. ciderlsp for some reason does not set
      -- the default text of the vim.ui.input when renaming by default.
      vim.keymap.set("n", "<leader>ra", function()
        vim.ui.input({
          prompt = "New name",
          default = vim.fn.expand("<cword>"),
        }, function(name)
          if name and name ~= "" then
            vim.lsp.buf.rename(name)
          end
        end)
      end, {
        buf = args.buf,
        desc = "ciderlsp rename",
      })

      vim.api.nvim_del_augroup_by_id(ciderlsp_attach_once_group)
    end,
  })
end)

vim.filetype.add({
  extension = {
    gcl = "gcl",
    txtpb = "pbtext",
  },
})
