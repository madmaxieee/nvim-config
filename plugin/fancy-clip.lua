local state = {}

function state:pre_tohtml()
  if vim.fn.exists(":IBLDisable") ~= 0 then
    vim.cmd("IBLDisable")
  end
  if require("snacks").words.is_enabled() then
    self.snacks_words_enabled = true
    require("snacks").words.disable()
  end
  self.colors_name = vim.g.colors_name
  vim.cmd.colorscheme("tokyonight-day")
end

function state:post_tohtml()
  if vim.fn.exists(":IBLEnable") ~= 0 then
    vim.cmd("IBLEnable")
  end
  if self.snacks_words_enabled then
    require("snacks").words.enable()
  end
  vim.cmd.colorscheme(self.colors_name)
end

local hammerspoon_code = [[
local file_path = _cli.args[2]

local file = io.open(file_path, "r")
if not file then
    io.stderr:write("fancy-clip: Failed to open file: " .. file_path)
    return
end
local raw_json = file:read("*a")
file:close()

if not raw_json then
    io.stderr:write("fancy-clip: Failed to read file: " .. file_path)
    return
end

local parsed = hs.json.decode(raw_json) if not parsed then
    io.stderr:write("fancy-clip: Failed to parse JSON content")
    return
end

hs.pasteboard.clearContents()
for uti, content in pairs(parsed) do
    hs.pasteboard.writeDataForUTI(nil, uti, content, true)
end
]]

vim.api.nvim_create_user_command("FancyClip", function(args)
  if vim.fn.executable("hs") == 0 then
    vim.notify(
      "fancy-clip: Hammerspoon CLI tool 'hs' not found.",
      vim.log.levels.ERROR
    )
    return
  end

  if args.range == 0 then
    args.line1 = 1
    args.line2 = vim.api.nvim_buf_line_count(0)
  elseif args.range == 1 then
    args.line2 = args.line1
  end
  local begin_line = args.line1
  local end_line = args.line2

  state:pre_tohtml()

  local html_lines = require("tohtml").tohtml(0, {
    range = { begin_line, end_line },
    -- for availability on google docs
    font = "JetBrains Mono",
  })

  state:post_tohtml()

  local raw_lines =
    vim.api.nvim_buf_get_lines(0, begin_line - 1, end_line, false)

  local backend_input_data = {
    ["public.html"] = table.concat(html_lines, "\n"),
    ["public.utf8-plain-text"] = table.concat(raw_lines, "\n"),
  }

  local encoded_data = vim.json.encode(backend_input_data)

  local fd, filename_or_err = vim.uv.fs_mkstemp("/tmp/fancy-clip-XXXXXX")
  assert(fd, "Failed to create temporary file: " .. filename_or_err)
  local tempfile_path = filename_or_err

  local bytes, err = vim.uv.fs_write(fd, encoded_data, -1)
  assert(
    bytes == #encoded_data,
    "Failed to write to temporary file: " .. (err or "unknown error")
  )

  local ok
  ok, err = vim.uv.fs_close(fd)
  assert(ok, err)

  vim.system(
    { "hs", "--", tempfile_path },
    { stdin = hammerspoon_code },
    function(out)
      assert(
        out.code == 0,
        "Failed to execute Hammerspoon script: " .. out.stderr
      )
    end
  )
end, {
  range = true,
  nargs = 0,
})
