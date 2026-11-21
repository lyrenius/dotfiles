-- Keybindings
--
-- The first part ports AeroSpace: its ctrl is SUPER here and its cmd is CTRL.
-- The rest keeps the CachyOS preset's bindings that do not collide with it:
-- Noctalia's launcher, panels, lock screen and screenshots, the hardware keys,
-- and some extra window controls.

local launch   = "uwsm app -- "
local noctalia = "noctalia msg "

local terminal    = "ghostty"
local fileManager = "dolphin"
local browser     = "firefox"
local editor      = "gnome-text-editor --new-window"
local calculator  = "gnome-calculator"

local directions = { h = "left", j = "down", k = "up", l = "right" }

-- AEROSPACE: MAIN -----------------------------------------------------

-- Like `open -a Ghostty`: focus a Ghostty window if there is one, otherwise
-- go to workspace 1, where the window rule puts Ghostty, and open one there.
local function focusOrOpenGhostty()
    for _, window in ipairs(hl.get_windows()) do
        if window.class == "com.mitchellh.ghostty" then
            hl.dispatch(hl.dsp.focus({ window = window }))
            return
        end
    end
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
    hl.dispatch(hl.dsp.exec_cmd(launch .. terminal))
end

hl.bind("CTRL + SUPER + Return", focusOrOpenGhostty)

-- Focus and move
for key, direction in pairs(directions) do
    hl.bind("CTRL + SUPER + " .. key,  hl.dsp.focus({ direction = direction }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Workspaces. Hyprland numbers workspaces from 1, so key 0 is workspace 10.
hl.bind("SUPER + grave", hl.dsp.focus({ workspace = "previous" }))
for i = 1, 10 do
    hl.bind("SUPER + " .. (i % 10), hl.dsp.focus({ workspace = i }))
end

-- Send the window without following it, as AeroSpace's move-node-to-workspace.
for i = 1, 9 do
    hl.bind("CTRL + SUPER + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind("CTRL + SUPER + 0", function()
    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    hl.dispatch(hl.dsp.window.move({ workspace = 10, follow = false }))
end)

hl.bind("SUPER + semicolon", hl.dsp.submap("service"))

-- AEROSPACE: SERVICE --------------------------------------------------

-- Dwindle picks split directions itself, so the AeroSpace commands that edit
-- the tree become their nearest equivalents. flatten-workspace-tree (t) has
-- none and is left out.
hl.define_submap("service", function()
    -- Layout: v and s choose where the next window opens, / flips the
    -- current split, and a groups windows into tabs (the accordion).
    hl.bind("v",     hl.dsp.layout("preselect r"))
    hl.bind("s",     hl.dsp.layout("preselect d"))
    hl.bind("slash", hl.dsp.layout("togglesplit"))
    hl.bind("a",     hl.dsp.group.toggle())
    hl.bind("f",     hl.dsp.window.fullscreen({ mode = "maximized" }))
    hl.bind("space", hl.dsp.window.float({ action = "toggle" }))
    hl.bind("b",     hl.dsp.layout("splitratio 1 exact"))

    -- Join: move the window into the group in that direction, or make one.
    for key, direction in pairs(directions) do
        hl.bind(key, hl.dsp.window.move({ into_or_create_group = direction }))
    end

    -- Utility
    hl.bind("m",         hl.dsp.focus({ monitor = "+1" }))
    hl.bind("SHIFT + m", hl.dsp.workspace.move({ monitor = "+1" }))
    hl.bind("r",         hl.dsp.submap("resize"))
    hl.bind("SHIFT + r", hl.dsp.reload_config())

    hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- AEROSPACE: RESIZE ---------------------------------------------------

hl.define_submap("resize", function()
    local steps = { h = { -50, 0 }, j = { 0, 50 }, k = { 0, -50 }, l = { 50, 0 } }
    for key, step in pairs(steps) do
        local x, y = step[1], step[2]
        hl.bind(key,             hl.dsp.window.resize({ x = x,     y = y,     relative = true }), { repeating = true })
        hl.bind("SHIFT + " .. key, hl.dsp.window.resize({ x = x / 5, y = y / 5, relative = true }), { repeating = true })
    end

    -- AeroSpace's smart resize follows the parent container's orientation;
    -- dwindle has no such notion, so these resize both ways.
    hl.bind("minus", hl.dsp.window.resize({ x = -50, y = -50, relative = true }), { repeating = true })
    hl.bind("equal", hl.dsp.window.resize({ x = 50,  y = 50,  relative = true }), { repeating = true })

    -- Dwindle cannot balance a whole workspace; this evens out the current split.
    hl.bind("b", hl.dsp.layout("splitratio 1 exact"))

    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- WINDOW MANAGEMENT ---------------------------------------------------

hl.bind("SUPER + Escape",      hl.dsp.exec_cmd("hyprctl kill"))
hl.bind("SUPER + Q",           hl.dsp.window.close())
hl.bind("SUPER + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + D",           hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + F",           hl.dsp.window.fullscreen())
hl.bind("SUPER + J",           hl.dsp.layout("togglesplit"))

-- Arrow keys, alongside AeroSpace's hjkl
local arrows = { Left = "left", Down = "down", Up = "up", Right = "right" }
for key, direction in pairs(arrows) do
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ direction = direction }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

hl.bind("ALT + Tab",   hl.dsp.window.cycle_next())
hl.bind("SUPER + Tab", hl.dsp.exec_cmd(noctalia .. "window-switcher"))

-- Move and resize with the mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Zoom (the number row's - and =, or the keypad's - and +)
local function zoom(delta)
    local factor = math.min(3.0, math.max(1.0, hl.get_config("cursor:zoom_factor") + delta))
    hl.config({ cursor = { zoom_factor = factor } })
end
hl.bind("SUPER + minus",   function() zoom(-0.3) end, { repeating = true })
hl.bind("SUPER + equal",   function() zoom(0.3) end,  { repeating = true })
hl.bind("SUPER + code:82", function() zoom(-0.3) end, { repeating = true })
hl.bind("SUPER + code:86", function() zoom(0.3) end,  { repeating = true })

-- WORKSPACES ----------------------------------------------------------

-- Neighboring workspaces, and the first empty one
hl.bind("SUPER + CTRL + Right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("SUPER + CTRL + Left",  hl.dsp.focus({ workspace = "m-1" }))
hl.bind("SUPER + CTRL + Down",  hl.dsp.focus({ workspace = "emptym" }))
hl.bind("SUPER + CTRL + SHIFT + Right", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind("SUPER + CTRL + SHIFT + Left",  hl.dsp.window.move({ workspace = "m-1" }))

hl.bind("SUPER + mouse_down",                hl.dsp.focus({ workspace = "m-1" }))
hl.bind("SUPER + mouse_up",                  hl.dsp.focus({ workspace = "m+1" }))
hl.bind("SUPER + CTRL + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "m-1" }))
hl.bind("SUPER + CTRL + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "m+1" }))

-- Scratchpad
hl.bind("SUPER + S",         hl.dsp.workspace.toggle_special())
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))

-- LAUNCHER ------------------------------------------------------------

hl.bind("SUPER + Return",        hl.dsp.exec_cmd(launch .. terminal))
hl.bind("SUPER + E",             hl.dsp.exec_cmd(launch .. fileManager))
hl.bind("SUPER + T",             hl.dsp.exec_cmd(launch .. editor))
hl.bind("SUPER + C",             hl.dsp.exec_cmd(launch .. calculator))
hl.bind("XF86Calculator",        hl.dsp.exec_cmd(launch .. calculator))
hl.bind("SUPER + W",             hl.dsp.exec_cmd(launch .. browser))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(launch .. terminal .. " -e btop"))

hl.bind("SUPER + Space",   hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"))
hl.bind("SUPER + period",  hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher /emo"))
hl.bind("SUPER + Z",       hl.dsp.exec_cmd(noctalia .. "settings-toggle"))
hl.bind("SUPER + X",       hl.dsp.exec_cmd(noctalia .. "panel-toggle control-center"))
hl.bind("SUPER + A",       hl.dsp.exec_cmd(noctalia .. "panel-toggle control-center notifications"))
hl.bind("SUPER + V",       hl.dsp.exec_cmd(noctalia .. "panel-toggle clipboard"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(noctalia .. "panel-toggle wallpaper"))
hl.bind("SUPER + L",       hl.dsp.exec_cmd(noctalia .. "session lock"))
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd(noctalia .. "panel-toggle session"))

-- Screen capture
hl.bind("SUPER + P",     hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind("Print",         hl.dsp.exec_cmd(noctalia .. "screenshot-region"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd(noctalia .. "screenshot-fullscreen"))

-- HARDWARE CONTROLS ---------------------------------------------------

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctalia .. "volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctalia .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctalia .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctalia .. "mic-mute"),    { locked = true })

hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(noctalia .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctalia .. "media toggle"),   { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(noctalia .. "media next"),     { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(noctalia .. "media previous"), { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(noctalia .. "brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctalia .. "brightness-down"), { locked = true, repeating = true })
