command -q mise; or return

# Interactive shells get full activation (tools update on directory change);
# other fish processes get the shims, as zsh login shells do.
if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end
