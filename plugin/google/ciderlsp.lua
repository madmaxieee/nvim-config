if not require("flags").in_google3 then
  return
end

local _CIDERLSP_UNSUPPORTED_METHODS_BY_FILE_TYPE = {
  -- keep-sorted start block=yes
  bzl = {
    ["textDocument/documentHighlight"] = true,
    ["textDocument/inlayHint"] = true,
  },
  gcl = {
    ["textDocument/documentHighlight"] = true,
    ["textDocument/inlayHint"] = true,
  },
  markdown = {
    ["textDocument/documentHighlight"] = true,
    ["textDocument/inlayHint"] = true,
  },
  proto = {
    ["textDocument/documentHighlight"] = true,
    ["textDocument/inlayHint"] = true,
  },
  typescript = {
    ["textDocument/documentHighlight"] = true,
  },
  -- keep-sorted end
}

local _LSP_SHOULD_DISABLE_WITH_CIDERLSP = {
  -- keep-sorted start
  "clangd",
  "copilot",
  "eslint",
  "gopls",
  "jdtls",
  "pyrefly",
  "ruff",
  "ts_ls",
  -- keep-sorted end
}

require("utils.lazy").on_load("nvim-lspconfig", function()
  for _, name in ipairs(_LSP_SHOULD_DISABLE_WITH_CIDERLSP) do
    vim.cmd("lsp disable " .. name)
  end

  -- http://cl/783896564
  vim.lsp.config("ciderlsp", {
    cmd = {
      "/google/bin/releases/cider/ciderlsp/ciderlsp",
      "--tooltag=nvim-lsp",
      "--noforward_sync_responses",
      "--cdpush_name=",
    },
    filetypes = {
      -- keep-sorted start
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
      -- keep-sorted end
    },

    ---@param client vim.lsp.Client
    on_init = function(client)
      local orig_supports_method = client.supports_method

      client.supports_method = function(self, method, bufnr)
        bufnr = vim._resolve_bufnr(bufnr)
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          local ft = vim.bo[bufnr].filetype
          local unsupported = _CIDERLSP_UNSUPPORTED_METHODS_BY_FILE_TYPE[ft]
          if unsupported and unsupported[method] then
            return false
          end
        end
        return orig_supports_method(self, method, bufnr)
      end
    end,

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

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("ciderlsp.attach", {}),
    callback = function(args)
      local ciderlsp_client = vim.lsp.get_client_by_id(args.data.client_id)
      if not (ciderlsp_client and ciderlsp_client.name == "ciderlsp") then
        return
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
    end,
  })
end)

vim.filetype.add({
  extension = {
    gcl = "gcl",
    txtpb = "pbtext",
  },
})
