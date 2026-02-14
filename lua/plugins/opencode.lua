---@type {pane_id:string?}
local provider = {}

local function get_pane_id()
  if provider.pane_id then
    local res = vim
      .system({
        "tmux",
        "list-panes",
        "-t",
        provider.pane_id,
      })
      :wait()
    if res.code ~= 0 then
      provider.pane_id = nil
    end
  end
  return provider.pane_id
end

---@param api_key string
local function create_opencode_pane(api_key)
  if get_pane_id() then
    return
  end
  -- stylua: ignore
  local OPENCODE_PANE_CMD = {
    -- create a new pain in detached mode (no focus)
    "tmux", "split-window", "-d",
    -- print the pane id to stdout so we can capture it
    "-P", "-F", "#{pane_id}",
    -- split horizontally and set the width to 35% of the screen
    "-h", "-p", "35",
    -- the opencode command
    "exec opencode --port",
  }
  vim.system(OPENCODE_PANE_CMD, {
    env = { GEMINI_API_KEY = api_key },
  }, function(res)
    if res.code ~= 0 then
      return
    end
    provider.pane_id = vim.trim(res.stdout)
      -- stylua: ignore
      vim.system({
        -- target the pane we just created
        "tmux", "set-option", "-t", provider.pane_id,
        -- disable allow-passthrough so the terminal does not send escape code
        -- to the vim pane
        "-p", "allow-passthrough", "off",
      })
  end)
end

---@param path string
---@param callback fun(api_key: string)
---@diagnostic disable-next-line: unused-function, unused-local
local function get_credential_from_op(path, callback)
  vim.system({ "op", "read", path }, function(res)
    if res.code ~= 0 then
      vim.notify(
        "Failed to get credential from 1password",
        vim.log.levels.ERROR
      )
      return
    end
    local api_key = vim.trim(res.stdout)
    callback(api_key)
  end)
end

---@param path string
---@return string?
local function get_credential_from_pass_sync(path)
  local result = vim
    .system({ "pass", path }, {
      env = { PASSWORD_STORE_GPG_OPTS = "--pinentry-mode cancel" },
      text = true,
    })
    :wait()
  if result.code ~= 0 then
    return nil
  else
    return vim.trim(result.stdout)
  end
end

---@param path string
---@param callback fun(api_key: string)
local function get_credential_from_pass(path, callback)
  local SecretInput = require("plugins.nui.secret_input")
  local event = require("nui.utils.autocmd").event

  local input = SecretInput({
    relative = "editor",
    position = "50%",
    size = { width = 40 },
    border = {
      style = "rounded",
      text = {
        top = "[unlock password store]",
        top_align = "center",
      },
    },
  }, {
    on_submit = function(value)
      vim.system({ "pass", path }, {
        env = {
          PASSWORD_STORE_GPG_OPTS = "--passphrase-fd 0 --pinentry-mode loopback",
        },
        stdin = value,
      }, function(res)
        if res.code ~= 0 then
          vim.schedule(function()
            vim.notify("Can't unlock password store", vim.log.levels.ERROR)
          end)
          return
        end
        local api_key = vim.trim(res.stdout)
        callback(api_key)
      end)
    end,
  })

  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })

  input:on(event.BufLeave, function()
    input:unmount()
  end)

  input:mount()
end

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    ---@module 'snacks'
    ---@diagnostic disable-next-line: missing-fields
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  init = function()
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
      provider = {
        start = function()
          local api_key = get_credential_from_pass_sync("gemini/cli")
          if api_key then
            create_opencode_pane(api_key)
          else
            get_credential_from_pass("gemini/cli", create_opencode_pane)
          end
        end,
        stop = function()
          local pane_id = get_pane_id()
          if pane_id then
            -- stylua: ignore
            vim.system({
              "tmux", "send-keys", "-t", pane_id,
              -- clear prompt then exit opencode
              "C-c", "/exit",
            })
            provider.pane_id = nil
          end
        end,
        toggle = function() end,
      },
    }
  end,
  keys = {
    {
      "<C-.>",
      mode = "n",
      function()
        if get_pane_id() then
          vim.system({ "tmux", "resize-pane", "-Z" })
        else
          -- trigger opencode.nvim to start the provider
          require("opencode").prompt("", {})
        end
      end,
      desc = "Toggle opencode",
    },
    {
      "<leader>ac",
      mode = "n",
      function()
        require("opencode").prompt("", { clear = true })
      end,
      desc = "Clear opencode prompt",
    },
    {
      "<C-s>",
      mode = "n",
      function()
        require("opencode").prompt("", { submit = true })
      end,
      desc = "Submit opencode prompt",
    },
    {
      "<leader>aa",
      mode = { "n", "x" },
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      desc = "Ask opencode…",
    },
    {
      "<leader>af",
      mode = { "n", "x" },
      function()
        require("opencode").select()
      end,
      desc = "Execute opencode action…",
    },
    {
      "go",
      mode = { "n", "x" },
      function()
        return require("opencode").operator("@this ")
      end,
      desc = "Add range to opencode",
      expr = true,
    },
    {
      "goo",
      mode = "n",
      function()
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
