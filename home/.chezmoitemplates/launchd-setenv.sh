{{- /*
  launchctl commands that give GUI apps the toolHomes entries named in
  launchd.env. The com.lyre.environment LaunchAgent runs them at login and
  the launchd-environment script runs them on apply. The directory is
  XDG_DATA_HOME's default, as exported by .zshenv.
*/ -}}
{{- range .launchd.env }}
{{- if not (hasKey $.toolHomes .) }}
{{- fail (printf "launchd.env: %q is not defined in toolHomes" .) }}
{{- end }}
launchctl setenv {{ . }} {{ joinPath $.chezmoi.homeDir ".local/share" (index $.toolHomes .) | squote }}
{{- end }}
