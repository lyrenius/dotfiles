status is-interactive; or return

# Typing shortcuts from CachyOS's fish config. Each one rewrites the command
# line as it is typed, so the real command is on screen before it runs.

# bash history expansion. !! is an abbreviation for the previous command line;
# it expands on Space or Enter.
function __shortcut_last_command
    set -q history[1]; or return 1
    printf '%s\n' $history[1]
end
abbr --add !! --position anywhere --function __shortcut_last_command

# !$ becomes the previous command's last argument, as typed, the moment $ is
# pressed. It is a key binding because fish checks syntax before expanding
# abbreviations on Enter, and a lone $ fails that check. With vi key bindings
# only insert mode is bound: $ in normal mode still moves to the line end.
# Alt-Up recalls earlier arguments one at a time.
function __shortcut_last_argument
    if test "$(commandline --current-token)" = '!'; and set -q history[1]
        commandline --current-token -- (commandline --input=$history[1] --current-token)
    else
        commandline --insert '$'
    end
end
if test "$fish_key_bindings" = fish_vi_key_bindings
    bind --mode insert '$' __shortcut_last_argument
else
    bind '$' __shortcut_last_argument
end

# .. becomes cd ../, ... becomes cd ../../, and so on for any run of dots.
function __shortcut_cd_up
    echo cd (string repeat --count (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function __shortcut_cd_up
