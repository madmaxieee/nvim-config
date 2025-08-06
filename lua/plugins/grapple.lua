return {
  cond = not require("modes").minimal_mode,
  "cbochs/grapple.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Grapple",
  opts = {
    icons = true,
    quick_select = "1234567890",
  },
  keys = {
    { "<leader>j", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },
    { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Toggle tag" },
    { "<leader>1", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
    { "<leader>2", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
    { "<leader>3", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
    { "<leader>4", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },
    { "<A-f>", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
    { "<A-d>", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
    { "<A-s>", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
    { "<A-a>", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },
    {
      "<S-Tab>",
      function()
        local wintype = vim.fn.win_gettype()
        if wintype ~= "popup" then
          require("grapple").cycle_tags "prev"
        end
      end,
      desc = "Go to previous tag",
    },
    {
      "<Tab>",
      function()
        local wintype = vim.fn.win_gettype()
        if wintype ~= "popup" then
          require("grapple").cycle_tags "next"
        end
      end,
      desc = "Go to next tag",
    },
  },
}
