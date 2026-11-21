-- Every monitor uses its preferred mode. Set a specific output, mode or scale
-- in ~/.config/hypr/local.lua, for example:
--
-- hl.monitor({ output = "DP-4", mode = "2560x1440@180", position = "auto", scale = 1 })
--
-- `hyprctl monitors all` lists the outputs and the modes each one supports.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
