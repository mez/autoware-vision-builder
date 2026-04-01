#!/usr/bin/env bash
# Copies build artifacts to the mounted /artifacts volume and exits.
set -euo pipefail

echo "====================================================="
echo " Copying artifacts to /artifacts ..."
echo "====================================================="

# compile_commands.json — primary Klocwork input
cp /autoware_ws/build/compile_commands.json /artifacts/compile_commands.json

# Full build tree — Klocwork may need headers/binaries for deep analysis
cp -r /autoware_ws/build /artifacts/build

# Build log for reference
cp /autoware_ws/build.log /artifacts/build.log

echo ""
echo "====================================================="
echo " Done. Artifacts written to /artifacts:"
echo "====================================================="
ls -lh /artifacts/
echo ""
echo " Feed to Klocwork with:"
echo "   kwbuildproject --compile-commands /artifacts/compile_commands.json \\"
echo "       --tables-directory ./kw_tables"
