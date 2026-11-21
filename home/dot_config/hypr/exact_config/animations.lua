-- The CachyOS preset's animations: short slides.

hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })
hl.curve("easy",  { type = "spring", mass = 1, stiffness = 500, damping = 35 })

hl.animation({ leaf = "global",              enabled = true, speed = 3, bezier = "quick" })
hl.animation({ leaf = "windows",             enabled = true, speed = 3, spring = "easy",  style = "slide" })
hl.animation({ leaf = "workspaces",          enabled = true, speed = 5, bezier = "quick", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2, bezier = "quick", style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 2, bezier = "quick", style = "slide bottom" })
