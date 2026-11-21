hl.config({
    -- Keep each split's direction once it is set. togglesplit (SUPER+J and
    -- the service mode's /) works only with this on.
    dwindle = {
        preserve_split = true,
    },

    -- Let "previous" keep alternating between two workspaces, like
    -- AeroSpace's workspace-back-and-forth.
    binds = {
        allow_workspace_cycles = true,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },

    -- Window swallowing stays off (the default): macOS has nothing like it.
    misc = {
        middle_click_paste = false,
        vrr = 3,
    },

    render = {
        direct_scanout = 2,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})
