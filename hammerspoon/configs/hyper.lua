return {
  {
    hyperKey = "F18",
    remap = {
      source = 0x700000039,
      sourceName = "Capslock",
      target = 0x70000006D,
      targetName = "F18"
    },
    keymaps = {
      {
        key = "t",
        type = "launch",
        target = "iTerm"
      },
      {
        key = "b",
        type = "launch",
        target = "Brave Browser"
      },
      {
        key = "c",
        type = "launch",
        target = "Hammerspoon"
      },
      {
        key = "a",
        type = "launch",
        target = "Activity Monitor"
      },
      {
        key = "f",
        type = "bundleId",
        target = "com.apple.finder"
      },
      {
        key = "q",
        type = "caffeinate",
        target = "lockScreen"
      },
      {
        key = "p",
        type = "launch",
        target = "1Password"
      }
    }
  }
}
