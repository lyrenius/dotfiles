-- Workspaces exist only while they hold windows, except 10 (key 0), the
-- floating fallback, which AeroSpace also kept alive while empty.
hl.workspace_rule({ workspace = "10", persistent = true })
