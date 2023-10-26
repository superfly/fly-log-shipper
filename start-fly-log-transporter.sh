#!/bin/bash
set -euo pipefail

template() { eval $'cat <<_EOF\n'"$(awk '1;END{print"_EOF"}')"; }
sponge() { cat <<<"$(cat)" >"$1"; }
filter() { for i in "$@"; do template <"$i" | sponge "$i" || rm "$i"; done; }
filter /etc/vector/sinks/*.toml 2>&-
echo 'Configured sinks:'
find /etc/vector/sinks -type f -exec basename -s '.toml' {} \;


vector -c /etc/vector/vector.toml -C /etc/vector/sinks &
/usr/local/bin/vector-monitor &

VECTOR_PID=$!
MONITOR_PID=$!

cleanup() {
    echo "Shutting down services..."
    kill $VECTOR_PID
    kill $MONITOR_PID
    exit 0
}

trap cleanup SIGINT SIGTERM

wait
