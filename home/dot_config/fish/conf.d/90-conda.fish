status is-interactive; or return

# Use the active installation instead of assuming a fixed install path.
set -l conda_exe $CONDA_EXE
test -x "$conda_exe"; or set conda_exe (command -s conda)
test -x "$conda_exe"; or return

set -l conda_setup ($conda_exe shell.fish hook 2>/dev/null)
if test $status -eq 0
    string join \n -- $conda_setup | source
else
    set -l conda_fish (path dirname (path dirname (path resolve $conda_exe)))/etc/fish/conf.d/conda.fish
    test -r $conda_fish; and source $conda_fish
end
