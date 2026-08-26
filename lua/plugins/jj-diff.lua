---@type LazySpec
return {
  "madmaxieee/jj-diff.nvim",
  cmd = {
    "JJDiff",
    "JJDiffIncludeParent",
    "JJDiffExcludeParent",
  },
  init = function()
    vim.api.nvim_create_user_command(
      "JJDiffTrunk",
      "JJDiff trunk()",
      { desc = "Set diff base to `trunk()`" }
    )
    vim.api.nvim_create_user_command(
      "JJDiffReset",
      "JJDiff @-",
      { desc = "Reset diff base to the default (`@-`)" }
    )
  end,
}
