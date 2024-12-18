local state_dir = vim.fn.stdpath "state"
if type(state_dir) == "table" then
  state_dir = state_dir[1]
end

return {
  cond = not vim.g.minimal_mode,
  "folke/persistence.nvim",
  event = "BufReadPre",
  init = function()
    local session_options = {
      "buffers",
      "curdir",
      "folds",
      "help",
      "tabpages",
      "winsize",
      "globals",
    }
    vim.o.sessionoptions = table.concat(session_options, ",")

    local persistence_group = vim.api.nvim_create_augroup("Persistence", { clear = true })
    local home = vim.fn.expand "~"
    local disabled_dirs = {
      [home] = true,
      [home .. "/Downloads"] = true,
      ["/private/tmp"] = true,
      ["/tmp"] = true,
    }

    -- disable persistence for certain directories
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
      group = persistence_group,
      callback = function()
        local cwd = vim.fn.getcwd()
        if vim.fn.argc() == 0 and not vim.g.started_with_stdin and not disabled_dirs[cwd] then
          require("persistence").load()
        else
          require("persistence").stop()
        end
      end,
      nested = true,
    })

    -- disable persistence if nvim started with stdin
    vim.api.nvim_create_autocmd({ "StdinReadPre" }, {
      group = persistence_group,
      callback = function()
        vim.g.started_with_stdin = true
      end,
    })
  end,
  opts = {
    dir = vim.fn.expand(state_dir) .. "/sessions/",
    need = 1,
    branch = true,
  },
  config = true,
}
