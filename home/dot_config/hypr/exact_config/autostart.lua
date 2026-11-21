-- Under UWSM, apps that should start with the session belong in XDG autostart.
-- These set up the session itself: the systemd user environment, the Noctalia
-- shell, and root's access to XWayland for graphical admin tools.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")
end)
