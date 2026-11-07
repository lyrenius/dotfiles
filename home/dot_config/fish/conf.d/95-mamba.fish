status is-interactive; or return

# Same lookup as integrations/95-mamba.zsh: MAMBA_EXE, then PATH, then next to
# conda. An existing MAMBA_ROOT_PREFIX is preserved.
set -l mamba_exe $MAMBA_EXE
test -x "$mamba_exe"; or set mamba_exe (command -s mamba)
if not test -x "$mamba_exe"; and set -q CONDA_EXE
    set mamba_exe (path dirname (path dirname (path resolve $CONDA_EXE)))/bin/mamba
end
test -x "$mamba_exe"; or return

set -gx MAMBA_EXE $mamba_exe
set -q MAMBA_ROOT_PREFIX; or set -gx MAMBA_ROOT_PREFIX (path dirname (path dirname (path resolve $mamba_exe)))

set -l mamba_setup ($MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX 2>/dev/null)
if test $status -eq 0
    string join \n -- $mamba_setup | source
else
    alias mamba $MAMBA_EXE
end
