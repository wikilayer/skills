#!/bin/sh
# Tells an agent session about unread Wikilayer account chat at the points
# where it cannot look away: when the session starts, when a prompt arrives
# and when it is about to stop. A hook cannot call MCP, so it asks the server
# with a wait ticket: the session calls get_chat_ticket once, and the hook
# that runs after that call keeps the answer for the session.

event=$1
command -v jq >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

input=$(cat)
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$session" ] || exit 0

data="${CLAUDE_PLUGIN_DATA:-${PLUGIN_DATA:-${XDG_STATE_HOME:-$HOME/.local/state}/wikilayer}}"
tickets="$data/chat-tickets"
ticket="$tickets/$session.json"

say() {
    jq -n --arg event "$1" --arg text "$2" \
        '{hookSpecificOutput: {hookEventName: $event, additionalContext: $text}}'
}

how_to_join="If this session takes part in the Wikilayer account chat, call get_chat_ticket with its session_name once. From then on it is told at every turn when it has unread messages."

if [ "$event" = ticket ]; then
    answer=$(printf '%s' "$input" | jq -r '
        .tool_response
        | if type == "object" and has("content") then .content else . end
        | if type == "array" then .[0].text else . end
        | if type == "string" then . else tojson end' 2>/dev/null)
    printf '%s' "$answer" | jq -e '.token and .wait_url and .session_name' >/dev/null 2>&1 || exit 0
    mkdir -p "$tickets"
    (umask 077 && printf '%s' "$answer" | jq '{session_name, wait_url, token}' >"$ticket")
    exit 0
fi

if [ "$event" = start ] && [ -d "$tickets" ]; then
    # A ticket lives a day at most, so an older file belongs to a session that is gone.
    find "$tickets" -name '*.json' -mtime +2 -delete 2>/dev/null
fi

if [ ! -s "$ticket" ]; then
    [ "$event" = start ] && say SessionStart "$how_to_join"
    exit 0
fi

name=$(jq -r '.session_name // empty' "$ticket" 2>/dev/null)
url=$(jq -r '.wait_url // empty' "$ticket" 2>/dev/null)
token=$(jq -r '.token // empty' "$ticket" 2>/dev/null)
if [ -z "$name" ] || [ -z "$url" ] || [ -z "$token" ]; then
    rm -f "$ticket"
    [ "$event" = stop ] || say "$([ "$event" = start ] && echo SessionStart || echo UserPromptSubmit)" \
        "The chat ticket saved for this session could not be read. $how_to_join"
    exit 0
fi

answer=$(curl -sS --max-time 5 -w '\n%{http_code}' \
    -H "Authorization: Bearer $token" "$url?seconds=0" 2>/dev/null) || exit 0
status=$(printf '%s' "$answer" | tail -n 1)
body=$(printf '%s' "$answer" | sed '$d')

case "$status" in
200) ;;
401 | 403)
    rm -f "$ticket"
    [ "$event" = stop ] || say "$([ "$event" = start ] && echo SessionStart || echo UserPromptSubmit)" \
        "The chat ticket of session '$name' is no longer accepted. $how_to_join"
    exit 0
    ;;
*) exit 0 ;;
esac

unread=$(printf '%s' "$body" | jq -r '.unread // 0' 2>/dev/null)
case "$unread" in '' | *[!0-9]*) exit 0 ;; esac

if [ "$unread" -eq 0 ]; then
    [ "$event" = start ] && say SessionStart "This session is '$name' in the Wikilayer account chat and has nothing unread there."
    exit 0
fi

notice="Session '$name' has $unread unread message(s) in the Wikilayer account chat. Call read_chat(session_name='$name', max=20) now, before anything else: they may change what you should do."

case "$event" in
start) say SessionStart "$notice" ;;
prompt) say UserPromptSubmit "$notice" ;;
stop)
    [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = true ] && exit 0
    jq -n --arg reason "$notice" '{decision: "block", reason: $reason}'
    ;;
esac
exit 0
