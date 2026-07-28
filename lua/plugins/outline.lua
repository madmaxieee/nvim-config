return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<A-b>", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  init = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "OUTLINE_*",
      callback = function(args)
        if vim.bo[args.buf].ft ~= "Outline" then
          return
        end
        local count = 0
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_config(win).relative == "" then
            count = count + 1
          end
        end
        if count == 1 then
          vim.cmd("q")
        end
      end,
    })
  end,
  ---@module 'outline'
  ---@type outline.SetupOpts
  opts = {
    outline_window = { position = "left" },
    providers = {
      priority = { "markdown", "lsp", "norg", "man" },
    },
    symbols = {
      icons = {
        -- align symbols with dropbar
        Array = { icon = "󰅪 ", hl = "Constant" },
        Boolean = { icon = " ", hl = "Boolean" },
        Class = { icon = " ", hl = "Type" },
        Component = { icon = "󰅴 ", hl = "Function" },
        Constant = { icon = "󰏿 ", hl = "Constant" },
        Constructor = { icon = " ", hl = "Special" },
        Enum = { icon = " ", hl = "Type" },
        EnumMember = { icon = " ", hl = "Identifier" },
        Event = { icon = " ", hl = "Type" },
        Field = { icon = " ", hl = "Identifier" },
        File = { icon = "󰈔 ", hl = "Identifier" },
        Fragment = { icon = "󰅴 ", hl = "Constant" },
        Function = { icon = "󰊕 ", hl = "Function" },
        Interface = { icon = " ", hl = "Type" },
        Key = { icon = "🔐 ", hl = "Type" },
        Macro = { icon = "󰁌 ", hl = "Function" },
        Method = { icon = "󰆧 ", hl = "Function" },
        Module = { icon = "󰏗 ", hl = "Include" },
        Namespace = { icon = "󰅩 ", hl = "Include" },
        Null = { icon = "󰢤 ", hl = "Type" },
        Number = { icon = "󰎠 ", hl = "Number" },
        Object = { icon = "󰅩 ", hl = "Type" },
        Operator = { icon = "󰆕 ", hl = "Identifier" },
        Package = { icon = "󰆦 ", hl = "Include" },
        Parameter = { icon = " ", hl = "Identifier" },
        Property = { icon = " ", hl = "Identifier" },
        StaticMethod = { icon = " ", hl = "Function" },
        String = { icon = "󰉾 ", hl = "String" },
        Struct = { icon = " ", hl = "Structure" },
        TypeAlias = { icon = " ", hl = "Type" },
        TypeParameter = { icon = "󰆩 ", hl = "Identifier" },
        Variable = { icon = "󰀫 ", hl = "Constant" },
      },
    },
  },
}
