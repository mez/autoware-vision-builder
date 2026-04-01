#!/usr/bin/env bash
# =============================================================================
# entrypoint.sh
# Cleans the pre-baked build, reruns under kwinject so Klocwork can intercept
# all compiler calls, then runs kwbuildproject to produce kw_tables.
# Klocwork client must be mounted from host at /opt/klocwork.
# =============================================================================
set -euo pipefail

export PATH=/opt/klocwork/bin:$PATH
export ONNXRUNTIME_ROOT=/opt/onnxruntime
export CC=/usr/bin/clang-20
export CXX=/usr/bin/clang++-20

# Verify Klocwork is reachable
if ! command -v kwinject &> /dev/null; then
    echo "ERROR: kwinject not found at /opt/klocwork/bin"
    echo "Make sure to mount the Klocwork client:"
    echo "  -v /opt/klocwork:/opt/klocwork"
    exit 1
fi

echo "====================================================="
echo " Klocwork version: $(kwcheck --version 2>/dev/null || echo unknown)"
echo " Clang version:    $(clang --version | head -1)"
echo "====================================================="

# Source ROS
source /opt/ros/kilted/setup.sh

echo ""
echo "====================================================="
echo " Step 1 -- Clean pre-baked build so kwinject gets"
echo "           fresh compiler calls"
echo "====================================================="
cd /autoware_ws
rm -rf build/ install/ log/
echo "  Clean done"

echo ""
echo "====================================================="
echo " Step 2 -- kwinject: tracing build with Klocwork"
echo "====================================================="
kwinject \
    --output /autoware_ws/kwinject.out \
    colcon build \
        --base-paths src/autoware_vision_pilot/VisionPilot/Production_Releases/0.9 \
        --symlink-install \
        --cmake-args \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_C_COMPILER=/usr/bin/clang-20 \
            -DCMAKE_CXX_COMPILER=/usr/bin/clang++-20 \
    2>&1 | tee /artifacts/build.log

echo ""
echo "====================================================="
echo " Step 3 -- kwbuildproject: building Klocwork tables"
echo "====================================================="
kwbuildproject \
    --tables-directory /artifacts/kw_tables \
    --force \
    /autoware_ws/kwinject.out \
    2>&1 | tee -a /artifacts/build.log

echo ""
echo "====================================================="
echo " Done. Artifacts written to /artifacts:"
echo "====================================================="
ls -lh /artifacts/
echo ""
echo " Load results into Klocwork server with:"
echo "   kwadmin --url http://<kw-server>:<port> load visionpilot /artifacts/kw_tables"