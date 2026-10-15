#!/usr/bin/env bash
# Stop the range. Add --clean to also wipe the generated flags.
set -euo pipefail
cd "$(dirname "$0")"
docker compose down -v
if [ "${1:-}" = "--clean" ]; then
  rm -rf generated
  echo "generated/ removed. The next ./up.sh will use fresh flags."
fi
