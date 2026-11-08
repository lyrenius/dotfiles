status is-interactive; or return

# done sends a desktop notification when a command that ran longer than 10 s
# finishes while its window is not focused. CachyOS ships it with its fish
# config, outside fish's search path; done reads these settings as it loads.
set -l done_fish /usr/share/cachyos-fish-config/conf.d/done.fish
test -r $done_fish; or return

set -g __done_min_cmd_duration 10000
set -g __done_notification_urgency_level low
source $done_fish
