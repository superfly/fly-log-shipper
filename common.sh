#!/bin/bash

template() { eval $'cat <<_EOF\n'"$(awk '1;END{print"_EOF"}')"; }
sponge() { cat <<<"$(cat)" >"$1"; }
filter() { for i in "$@"; do template <"$i" | sponge "$i" || rm "$i"; done; }