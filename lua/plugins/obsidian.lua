local vault_folder = vim.fn.resolve(vim.fn.expand "~/obsidian")

local command_map = {
  ["backlinks"] = "ObsidianBacklinks",
  ["check"] = "ObsidianCheck",
  ["followlink"] = "ObsidianFollowLink",
  ["link"] = "ObsidianLink",
  ["linknew"] = "ObsidianLinkNew",
  ["new"] = "ObsidianNew",
  ["open"] = "ObsidianOpen",
  ["pasteimg"] = "ObsidianPasteImg",
  ["quickswitch"] = "ObsidianQuickSwitch",
  ["rename"] = "ObsidianRename",
  ["search"] = "ObsidianSearch",
  ["template"] = "ObsidianTemplate",
  ["today"] = "ObsidianToday",
  ["tomorrow"] = "ObsidianTomorrow",
  ["workspace"] = "ObsidianWorkspace",
  ["yesterday"] = "ObsidianYesterday",
}

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  cmd = "Obsidian",
  event = {
    "BufReadPre " .. vault_folder .. "/**.md",
    "BufNewFile " .. vault_folder .. "/**.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
      pattern = vault_folder .. "/**.md",
      callback = function()
        vim.wo.conceallevel = 1
      end,
    })
  end,
  opts = {
    workspaces = {
      {
        name = "notes",
        path = "~/obsidian/notes",
      },
      {
        name = "obsidian",
        path = "~/obsidian/obsidian",
      },
    },
    -- templates = {
    --   subdir = "templates",
    --   date_format = "%Y-%m-%d",
    --   time_format = "%H:%M",
    --   substitutions = {},
    -- },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    vim.api.nvim_create_user_command("Obsidian", function(_opts)
      local command
      if #_opts.fargs == 0 then
        command = "ObsidianOpen"
      else
        command = command_map[_opts.fargs[1]]
      end
      if command then
        vim.cmd(command)
      else
        vim.notify("Invalid Obsidian command: " .. opts[1], vim.log.levels.ERROR)
      end
    end, {
      nargs = "*",
      complete = function(_, line)
        local l = vim.split(line, "%s+")
        local options_list = vim.tbl_keys(command_map)
        return vim.tbl_filter(function(val)
          return vim.startswith(val, l[#l])
        end, options_list)
      end,
    })
  end,
}
