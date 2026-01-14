return {
  {
    "vicentecaycedo/cmp-buganizer",
    url = "sso://user/vicentecaycedo/cmp-buganizer",
    event = "InsertEnter",
    opts = {},
  },

  {
    -- TODO: contribute my patch
    "vintharas/cmp-googlers.nvim",
    url = "sso://user/vintharas/cmp-googlers.nvim",
    event = "InsertEnter",
    opts = {
      get_users = function(prefix)
        local users_file_path =
          "/usr/share/vim/google/googlespell/spell/current-eng-googlers"
        local num_results = 15
        local command = string.format(
          "rg --ignore-case ^%s --max-count=%d %s",
          vim.fn.shellescape(prefix),
          num_results,
          users_file_path
        )
        if prefix == "" then
          command =
            string.format("head --lines=%d %s", num_results, users_file_path)
        end
        local handle = io.popen(command)
        if not handle then
          return {}
        end
        local users = {}
        for line in handle:lines() do
          table.insert(users, line)
        end
        handle:close()
        return users
      end,
    },
  },

  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "buganizer", "googlers" },
        providers = {
          buganizer = {
            name = "buganizer",
            module = "blink.compat.source",
          },
          googlers = {
            name = "googlers",
            module = "blink.compat.source",
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
