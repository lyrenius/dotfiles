-- Hyprland configuration (Lua, Hyprland 0.55 and later)
--
-- Ported from AeroSpace on macOS: AeroSpace's ctrl is SUPER here and its cmd
-- is CTRL. Noctalia provides the bar, launcher, notifications, lock screen,
-- wallpaper, screenshots and clipboard, as in CachyOS's cachyos-hypr-noctalia
-- preset this replaces.
--
-- Each require runs in its own scope, so an error in one file does not stop
-- the others from loading.

require("config.monitors")
require("config.inputs")
require("config.decorations")
require("config.animations")
require("config.misc")
require("config.autostart")
require("config.binds")
require("config.windowrules")
require("config.workspaces")

-- Machine-specific settings (monitor modes, devices) go in local.lua next to
-- this file. chezmoi does not manage it, and it is loaded only if it exists.
pcall(require, "local")
