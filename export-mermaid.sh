#!/usr/bin/env bash
# Regenerates structurizr/mermaid/*.mmd from workspace.dsl, one file per view, themed for a dark
# Notion page.
#
# Structurizr's Mermaid export assumes a white page, so the sed below adapts it:
# - adds Mermaid's dark theme;
# - `linkStyle default fill:#ffffff` makes Mermaid 11 draw edge-label text white; set a light grey;
# - boundary and frame fills are white; use Notion's dark page colour (#191919);
# - in-scope boundary outlines use the dark-green stroke; use a lighter green that shows on dark.
# - flow views export as sequence diagrams without step numbers; add Mermaid's autonumber.
# Element fills (green, amber, grey) come from workspace.dsl unchanged.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

structurizr export -w "$here/workspace.dsl" -f mermaid -o "$here/mermaid" 2>&1 | grep -v -E '^WARNING' || true
# The autonumber rule runs first: the init rule then prepends to the same first line.
sed -i '' \
  -e 's/^sequenceDiagram$/sequenceDiagram\n  autonumber/' \
  -e '1s/^/%%{init: {"theme": "dark"}}%%\n/' \
  -e 's/linkStyle default fill:#ffffff/linkStyle default color:#dddddd/' \
  -e 's/fill:#ffffff/fill:#191919/g' \
  -e 's/stroke:#ffffff/stroke:#191919/g' \
  -e 's/stroke:#0f4d39,color:#0f4d39/stroke:#4fbf95,color:#4fbf95/g' \
  "$here"/mermaid/*.mmd
ls "$here"/mermaid/*.mmd
