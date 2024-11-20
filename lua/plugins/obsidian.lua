local vault_folder = vim.fn.resolve(vim.fn.expand "~/obsidian")

local command_map = {
  backlinks = "ObsidianBacklinks",
  dailies = "ObsidianDailes",
  extract = "ObsidianExtractNote",
  follow = "ObsidianFollowLink",
  link = "ObsidianLink",
  links = "ObsidianLinks",
  linknew = "ObsidianLinkNew",
  new = "ObsidianNew",
  newfromtemplate = "ObsidianNewFromTemplate",
  open = "ObsidianOpen",
  pasteimg = "ObsidianPasteImg",
  rename = "ObsidianRename",
  search = "ObsidianSearch",
  switch = "ObsidianQuickSwitch",
  tags = "ObsidianTags",
  template = "ObsidianTemplate",
  toc = "ObsidianTOC",
  today = "ObsidianToday",
  tomorrow = "ObsidianTomorrow",
  check = "ObsidianToggleCheckbox",
  workspace = "ObsidianWorkspace",
  yesterday = "ObsidianYesterday",
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
    "nvim-telescope/telescope.nvim",
  },
  init = function()
    vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
      pattern = vault_folder .. "/**.md",
      callback = function()
        vim.wo.conceallevel = 1
      end,
    })
    vim.cmd.cabbrev("O", "Obsidian")
    local map = require("utils").safe_keymap_set
    map("n", "<leader>fo", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian search" })
  end,
  config = function()
    require("obsidian").setup {
      workspaces = {
        {
          name = "notes",
          path = "~/obsidian/notes",
        },
      },
    }
    vim.api.nvim_create_user_command("Obsidian", function(opts)
      local command = command_map[opts.fargs[1]]
      local real_args = table.concat(opts.fargs, " ", 2)
      if command then
        vim.cmd(command .. " " .. real_args)
      else
        vim.notify("Invalid Obsidian command: " .. opts.fargs[1], vim.log.levels.ERROR)
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
