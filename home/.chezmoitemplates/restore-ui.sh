# 24-bit foreground escape for a #RRGGBB color.
ui_rgb() {
    ui_hex=${1#\#}
    printf '\033[38;2;%d;%d;%dm' "0x$(printf %s "$ui_hex" | cut -c1-2)" \
        "0x$(printf %s "$ui_hex" | cut -c3-4)" "0x$(printf %s "$ui_hex" | cut -c5-6)"
}

# Colors come from the palette in .chezmoidata.toml.
ui_init() {
    if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
        UI_RESET=$(printf '\033[0m')
        UI_ACCENT=$(ui_rgb '{{ .palette.accent }}')
        UI_GREEN=$(ui_rgb '{{ .palette.green }}')
        UI_GOLD=$(ui_rgb '{{ .palette.gold }}')
        UI_RED=$(ui_rgb '{{ .palette.red }}')
        UI_MUTED=$(ui_rgb '{{ .palette.muted }}')
    else
        UI_RESET=''
        UI_ACCENT=''
        UI_GREEN=''
        UI_GOLD=''
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
    printf '\n%s◆%s %s\n' "$UI_ACCENT" "$UI_RESET" "$1"
}

ui_step() {
    printf '  %s›%s %s\n' "$UI_ACCENT" "$UI_RESET" "$1"
}

ui_ok() {
    printf '  %s✓%s %s\n' "$UI_GREEN" "$UI_RESET" "$1"
}

ui_warn() {
    printf '  %s!%s %s\n' "$UI_GOLD" "$UI_RESET" "$1"
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
