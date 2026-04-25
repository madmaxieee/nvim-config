return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    ---@module 'snacks'
    ---@diagnostic disable-next-line: missing-fields
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },

  init = function()
    local pane = require("opencode_pane")
    local kv = require("kv")

    -- Restore opencode pane after restart if it was active
    if kv.get("opencode_restore") then
      kv.set("opencode_restore", false)
      kv.save()
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          vim.schedule(require("opencode").start)
        end,
      })
    end

    ---@module 'opencode'
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      contexts = {
        ["@file"] = function(context)
          return context:buffer()
        end,
        ["@tab"] = function()
          local paths = {}
          local tabnr = vim.api.nvim_get_current_tabpage()
          local windows = vim.api.nvim_tabpage_list_wins(tabnr)
          for _, win in ipairs(windows) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            if vim.bo[bufnr].buftype == "" then
              local full_path = vim.api.nvim_buf_get_name(bufnr)
              local rel_path = vim.fn.fnamemodify(full_path, ":.")
              if rel_path ~= "" then
                table.insert(paths, rel_path)
              end
            end
          end
          return table.concat(paths, " ")
        end,
        ---@diagnostic disable-next-line: assign-type-mismatch
        ["@marks"] = false,
        ---@diagnostic disable-next-line: assign-type-mismatch
        ["@buffer"] = false,
        ---@diagnostic disable-next-line: assign-type-mismatch
        ["@buffers"] = false,
      },
      server = {
        start = function()
          pane.create_pane()
        end,
        stop = function()
          local pane_id = pane.get_pane_id()
          if pane_id then
            -- stylua: ignore
            vim.system({
              "tmux", "send-keys", "-t", pane_id,
              -- clear prompt then exit opencode
              "C-c", "/exit",
            })
            pane.clear_pane_id()
          end
        end,
        toggle = function() end,
      },
    }
    vim.api.nvim_create_autocmd("VimLeave", {
      group = vim.api.nvim_create_augroup("opencode.cleanup", { clear = true }),
      desc = "ceanup opencode pane on exit",
      callback = function()
        require("opencode").stop()
      end,
    })
  end,

  keys = {
    {
      "<C-.>",
      mode = "n",
      function()
        local pane = require("opencode_pane")
        require("opencode").start()
        if pane.get_pane_id() then
          vim.system({ "tmux", "select-pane", "-t", pane.get_pane_id() })
        end
      end,
      desc = "Toggle opencode",
    },
    {
      "<leader>aa",
      mode = { "n", "x" },
      function()
        require("opencode").start()
        require("opencode").ask("", { submit = true })
      end,
      desc = "Ask opencode",
    },
    {
      "<leader>at",
      mode = { "n", "x" },
      function()
        require("opencode").start()
        require("opencode").ask("@this ", { submit = true })
      end,
      desc = "Ask opencode about @this",
    },
    {
      "<leader>af",
      mode = { "n", "x" },
      function()
        require("opencode").start()
        require("opencode").select()
      end,
      desc = "Execute opencode action…",
    },
    {
      "go",
      mode = { "n", "x" },
      function()
        require("opencode").start()
        return require("opencode").operator("@this ")
      end,
      desc = "Add range to opencode",
      expr = true,
    },
    {
      "goo",
      mode = "n",
      function()
        require("opencode").start()
        return require("opencode").operator("@this ") .. "_"
      end,
      desc = "Add line to opencode",
      expr = true,
    },
    {
      "<S-C-u>",
      mode = "n",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "Scroll opencode up",
    },
    {
      "<S-C-d>",
      mode = "n",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "Scroll opencode down",
    },
  },
}
