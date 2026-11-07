ui_init() {
    if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
        UI_RESET=$(printf '\033[0m')
        UI_TEAL=$(printf '\033[38;2;128;203;196m')
        UI_GREEN=$(printf '\033[38;2;195;232;141m')
        UI_YELLOW=$(printf '\033[38;2;255;203;107m')
        UI_RED=$(printf '\033[38;2;240;113;120m')
        UI_MUTED=$(printf '\033[38;2;103;103;103m')
    else
        UI_RESET=''
        UI_TEAL=''
        UI_GREEN=''
        UI_YELLOW=''
        UI_RED=''
        UI_MUTED=''
    fi
}

ui_prepare_log() {
    UI_LOG_DIR=${XDG_STATE_HOME:-"$HOME/.local/state"}/chezmoi
    mkdir -p "$UI_LOG_DIR"
    chmod 0700 "$UI_LOG_DIR"
    UI_LOG_FILE="$UI_LOG_DIR/restore-$1.log"
    : > "$UI_LOG_FILE"
    chmod 0600 "$UI_LOG_FILE"
}

ui_title() {
    printf '\n%s◆%s %s\n' "$UI_TEAL" "$UI_RESET" "$1"
}

ui_step() {
    printf '  %s›%s %s\n' "$UI_TEAL" "$UI_RESET" "$1"
}

ui_ok() {
    printf '  %s✓%s %s\n' "$UI_GREEN" "$UI_RESET" "$1"
}

ui_warn() {
    printf '  %s!%s %s\n' "$UI_YELLOW" "$UI_RESET" "$1"
}

ui_note() {
    printf '    %s%s%s\n' "$UI_MUTED" "$1" "$UI_RESET"
}

ui_error() {
    printf '  %s✗%s %s\n' "$UI_RED" "$UI_RESET" "$1" >&2
}

ui_die() {
    ui_error "$1"
    exit 1
}

ui_die_log() {
    ui_error "$1"
    if [ -s "$UI_LOG_FILE" ]; then
        printf '\n%sLast log lines:%s\n' "$UI_MUTED" "$UI_RESET" >&2
        tail -n 40 "$UI_LOG_FILE" >&2
    fi
    printf '\n%sFull log: %s%s\n' "$UI_MUTED" "$UI_LOG_FILE" "$UI_RESET" >&2
    exit 1
}

ui_done() {
    ui_ok "$1"
    ui_note "log $UI_LOG_FILE"
}
