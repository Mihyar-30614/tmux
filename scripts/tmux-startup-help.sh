#!/usr/bin/env bash
set -u
set -o pipefail

MODE="${1:-attach}"

STAMP_DIR="${TMPDIR:-/tmp}/tmux-help"
mkdir -p "$STAMP_DIR" 2>/dev/null || true
CLIENT_ID="${TMUX_CLIENT:-${TMUX_PANE:-$$}}"
STAMP_FILE="$STAMP_DIR/$CLIENT_ID"

# Only show automatically once per client
if [ "$MODE" = "attach" ] && [ -f "$STAMP_FILE" ]; then
  exit 0
fi
: > "$STAMP_FILE" 2>/dev/null || true

prefix_key="$(tmux show -g -v prefix 2>/dev/null || echo 'C-b')"

tmux display-popup -w 80% -h 80% -E "bash -lc '
clear
cat <<EOF
TMUX QUICK HELP (your custom keys)

Prefix: ${prefix_key}

SESSIONS
  ${prefix_key} F     fuzzy switch session (popup)
  ${prefix_key} C     create/attach by name (prompt)
  ${prefix_key} R     rename session
  ${prefix_key} K     fuzzy kill session
  ${prefix_key} Tab   toggle last session
  ${prefix_key} s     browse sessions/windows/panes (choose-tree)

WINDOWS
  ${prefix_key} W     fuzzy switch window (all sessions)
  ${prefix_key} c     new window in current dir
  ${prefix_key} n     next window
  ${prefix_key} p     previous window
  ${prefix_key} C-h   previous window (repeatable)
  ${prefix_key} C-l   next window (repeatable)
  ${prefix_key} X     kill current window

PANES
  ${prefix_key} P     fuzzy switch pane (all sessions)
  ${prefix_key} h/j/k/l  vim-style pane navigation
  ${prefix_key} H/J/K/L  resize pane (repeatable)
  ${prefix_key} z     toggle pane zoom (fullscreen)
  ${prefix_key} x     kill current pane
  ${prefix_key} -     split below (keep cwd)
  ${prefix_key} _     split right (keep cwd)
  ${prefix_key} |     split right (alternative)
  Mouse               click to select / resize

COPY MODE
  ${prefix_key} [     enter copy mode (vi keys enabled)
  v                   begin selection
  y                   copy and exit
  C-v                 rectangle/block selection
  Escape              cancel

SHELL HELPERS (use in your shell)
  ts <name>    create-or-attach session
  tls          List all sessions name
  ta           fuzzy switch session
  tks          fuzzy kill session
  pj           pick project dir -> session

Press q to close
EOF

# wait for q
while :; do
  IFS= read -rsn1 key || continue
  [ \"\$key\" = q ] && break
done
'" >/dev/null 2>&1 || true

exit 0

