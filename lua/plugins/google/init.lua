if not require("flags").on_glinux then
  return {}
end

return {
  {
    import = "plugins.google",
  },
}
