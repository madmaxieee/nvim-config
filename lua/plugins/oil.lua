-- helper function to parse output
local function parse_output(proc)
  local result = proc:wait()
  local ret = {}
  if result.code == 0 then
    for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
      -- Remove trailing slash
      line = line:gsub("/$", "")
      ret[line] = true
    end
  end
  return ret
end

-- build git status cache
local function new_git_status()
  return setmetatable({}, {
    __index = function(self, key)
      local ignore_proc = vim.system(
        { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
        {
          cwd = key,
          text = true,
        }
      )
      local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
        cwd = key,
        text = true,
      })
      local ret = {
        ignored = parse_output(ignore_proc),
        tracked = parse_output(tracked_proc),
      }
      rawset(self, key, ret)
      return ret
    end,
  })
end
local git_status = new_git_status()

return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  keys = {
    {
      "<leader>o",
      mode = "n",
      function()
        local oil = require "oil"
        if vim.w.is_oil_win then
          oil.close()
        else
          oil.open_float(nil, { preview = { vertical = true } })
        end
      end,
      desc = "Toggle oil",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Clear git status cache on refresh
    local refresh = require("oil.actions").refresh
    local orig_refresh = refresh.callback
    refresh.callback = function(...)
      git_status = new_git_status()
      orig_refresh(...)
    end

    require("oil").setup {
      view_options = {
        is_hidden_file = function(name, bufnr)
          local dir = require("oil").get_current_dir(bufnr)
          if not dir then
            return false
          end
          return git_status[dir].ignored[name]
        end,
      },
      -- Configuration for the floating window in oil.open_float
      float = {
        max_width = 0.6,
        max_height = 0.7,
      },
      preview_win = {
        win_options = {
          wrap = false,
        },
      },
    }
  end,
}
