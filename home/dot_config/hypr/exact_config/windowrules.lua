-- Window rules
--
-- Static rules see the class and title a window has when it opens.
-- `hyprctl clients` shows them for open windows. Classes marked "unchecked"
-- come from desktop files and have not been seen on a running window yet.

local pictureInPicture = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"

-- Floating windows reopen at the size they last had.
hl.window_rule({ match = { float = true }, persistent_size = true })

-- Workspaces, as in AeroSpace -------------------------------------------
-- "silent" keeps the focus where it is, like AeroSpace's
-- move-node-to-workspace.

-- 1: terminal
hl.window_rule({
    name      = "ws1-ghostty",
    match     = { class = "^(com\\.mitchellh\\.ghostty)$" },
    workspace = "1 silent",
    float     = true,
})

-- 2: web. Picture-in-picture windows stay where they open.
hl.window_rule({
    name      = "ws2-web",
    match     = { class = "^(firefox|zen)$", title = "negative:" .. pictureInPicture },
    workspace = "2 silent",
})

-- 3: code (unchecked)
hl.window_rule({
    name      = "ws3-code",
    match     = { class = "(?i)^(code|code-url-handler|com\\.microsoft\\.vscode)$" },
    workspace = "3 silent",
})

-- 4: agents. ChatGPT is checked, Claude is not.
hl.window_rule({
    name      = "ws4-agents",
    match     = { class = "(?i)^(com\\.anthropic\\.claude|claude|chatgpt)$" },
    workspace = "4 silent",
})

-- 10 (key 0): file manager, floating. Dolphin's progress and settings
-- dialogs open where Dolphin is.
hl.window_rule({
    name  = "ws10-dolphin",
    match = {
        class = "^(org\\.kde\\.dolphin|dolphin)$",
        title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
    workspace = "10 silent",
    float     = true,
    size      = { "max(monitor_w, monitor_h)*0.50", "min(monitor_w, monitor_h)*0.55" },
    center    = true,
})

-- 10: floating fallback. Windows opened on workspace 10 float.
hl.window_rule({ name = "ws10-float", match = { workspace = "10" }, float = true })

-- Floating ------------------------------------------------------------

-- Settings and system tools, the counterparts of the macOS apps AeroSpace
-- floated. The last group is unchecked.
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org\\.pulseaudio\\.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { class = "(?i)^(btrfs-assistant|cachyos-hello|.*kernel-?manager.*|.*scx-?manager.*|system-config-printer|nvidia-settings)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, match in ipairs(floatApps) do hl.window_rule({ match = match, float = true }) end

hl.window_rule({
    match = { class = "^(.*[Cc]alc.*)$" },
    float = true,
    size  = { "max(monitor_w, monitor_h)*0.17", "min(monitor_w, monitor_h)*0.43" },
})
hl.window_rule({
    match = { class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" },
    float = true,
    size  = { "monitor_w*0.70", "monitor_h*0.70" },
})
hl.window_rule({
    match    = { class = "^(.*swash)$", title = "^(Swash)$" },
    float    = true,
    min_size = { "max(monitor_w, monitor_h)*0.35", "min(monitor_w, monitor_h)*0.35" },
})
hl.window_rule({ match = { class = "^(org\\.kde\\.keditfiletype)$" }, float = true })
hl.window_rule({
    match = { class = "^(org\\.kde\\.ark)$" },
    size  = { "max(monitor_w, monitor_h)*0.40", "min(monitor_w, monitor_h)*0.40" },
})
hl.window_rule({ match = { class = "^(.*[Ll]auncher.*)$" }, float = true })
hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, center = true, fullscreen_state = 0 })

-- Common dialogs
local dialogs = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$" },
}
for _, match in ipairs(dialogs) do hl.window_rule({ match = match, float = true }) end

-- Picture-in-picture: small, floating, on every workspace.
hl.window_rule({
    match             = { title = pictureInPicture },
    float             = true,
    keep_aspect_ratio = true,
    size              = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
    pin               = true,
})

-- Gaming --------------------------------------------------------------

local gamingApps = "^(steam_app.*|gamescope)$"
local gaming = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gaming })
hl.window_rule({ match = { xdg_tag = "^(.*game.*)$" }, workspace = gaming, fullscreen_state = 2, content = "game", sync_fullscreen = true })
hl.window_rule({ match = { class = gamingApps }, workspace = gaming })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Launching\\.{3})$" }, float = true, center = true, workspace = gaming })
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    content          = "game",
    decorate         = false,
    fullscreen_state = 2,
    size             = { "monitor_w", "monitor_h" },
    sync_fullscreen  = true,
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    center           = true,
    float            = true,
    fullscreen       = false,
    fullscreen_state = 0,
    workspace        = gaming,
})

-- Fixes ---------------------------------------------------------------

-- Ignore maximize requests from apps.
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Noctalia's bar, panels and notifications
hl.layer_rule({
    name  = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim      = true,
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})
