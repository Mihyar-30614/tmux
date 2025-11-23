#!/usr/bin/env bash
# Be tolerant: only -u and pipefail; avoid -e so minor errors don't abort
set -u
set -o pipefail

MODE="${1:-attach}"

# Stamp so we only auto-show once per client (attach mode)
STAMP_DIR="${TMPDIR:-/tmp}/tmux-help" ; mkdir -p "$STAMP_DIR" 2>/dev/null || true
CLIENT_ID="${TMUX_CLIENT:-${TMUX_PANE:-$$}}"
STAMP_FILE="$STAMP_DIR/$CLIENT_ID"

if [ "$MODE" = "attach" ] && [ -f "$STAMP_FILE" ]; then
  exit 0
fi
: > "$STAMP_FILE" 2>/dev/null || true

# Detect prefix; default to C-b if we can’t read it
prefix_key="$(tmux show -g -v prefix 2>/dev/null || echo 'C-b')"

# Open a popup; if popup fails, just silent-success so tmux doesn't show "returned 1"
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
  ${prefix_key} -     split right  (keep cwd)
  ${prefix_key} _     split below (keep cwd)

PANES
  ${prefix_key} P     fuzzy switch pane (all sessions)
  Mouse               click to select / resize

COPY MODE
  ${prefix_key} [     enter copy mode (vi keys enabled)
  v / y               select / copy

SHELL HELPERS (use in your shell)
  ts <name>    create-or-attach session
  ta           fuzzy switch session
  tks          fuzzy kill session
  pj           pick project dir -> session

Press q to close
EOF

# Wait for q or ESC
while :; do
  IFS= read -rsn1 key || continue
  [[ \$key == q ]] && break
done
'" >/dev/null 2>&1 || true

exit 0

