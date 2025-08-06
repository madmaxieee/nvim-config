-- allow neovim to access the lua modules installed via luarocks
package.path = package.path
  .. ";"
  .. (vim.fn.expand "$HOME" .. "/.luarocks/share/lua/5.1/?/init.lua;")
  .. (vim.fn.expand "$HOME" .. "/.luarocks/share/lua/5.1/?.lua;")

require "config.opts"
require "config.autocmd"

require "config.lazy"

require "config.usercmd"
require "config.keymaps"
require "config.filetype"
