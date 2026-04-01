# =============================================================================
# Dockerfile — autoware_vision_pilot v0.9 Klocwork build environment
#
# Provides a clean build environment for kwinject to intercept compiler calls.
# The actual build and Klocwork analysis happen at runtime via entrypoint.sh.
# Klocwork client must be installed on the HOST and mounted at runtime.
#
# Usage:
#   docker build -t visionpilot-build .
#   docker run --rm \
#     -v /opt/klocwork:/opt/klocwork \
#     -v $(pwd)/artifacts:/artifacts \
#     visionpilot-build
#
# Output:
#   artifacts/kw_tables/    <-- load into Klocwork server with kwadmin
#   artifacts/build.log     <-- build log
# =============================================================================

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_DISTRO=kilted
ENV CLANG_VER=20
ENV ONNXRUNTIME_VERSION=1.24.4
ENV ONNXRUNTIME_ROOT=/opt/onnxruntime
ENV CC=/usr/bin/clang-20
ENV CXX=/usr/bin/clang++-20

# Klocwork client is mounted from host at runtime — just add to PATH here
ENV PATH=/opt/klocwork/bin:$PATH

# -----------------------------------------------------------------------------
# 1. Locale + base tools
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    locales curl wget gnupg2 lsb-release ca-certificates \
    software-properties-common apt-transport-https \
    git git-lfs build-essential cmake ninja-build \
    python3-pip python3-venv python3-dev \
    libeigen3-dev libopencv-dev pkg-config \
    libboost-all-dev \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 2. Clang 20 via apt.llvm.org
# -----------------------------------------------------------------------------
RUN wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh \
    && chmod +x /tmp/llvm.sh \
    && /tmp/llvm.sh ${CLANG_VER} \
    && apt-get install -y \
        clang-tidy-${CLANG_VER} \
        clang-format-${CLANG_VER} \
        clang-tools-${CLANG_VER} \
        lld-${CLANG_VER} \
        llvm-${CLANG_VER} \
        llvm-${CLANG_VER}-dev \
        libc++-${CLANG_VER}-dev \
        libc++abi-${CLANG_VER}-dev \
    && update-alternatives --install /usr/bin/clang   clang   /usr/bin/clang-${CLANG_VER}   100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VER} 100 \
    && update-alternatives --install /usr/bin/cc      cc      /usr/bin/clang-${CLANG_VER}   100 \
    && update-alternatives --install /usr/bin/c++     c++     /usr/bin/clang++-${CLANG_VER} 100 \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 3. ROS 2 Kilted via ros2-apt-source (official method)
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y curl software-properties-common \
    && add-apt-repository universe \
    && export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb \
        "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb \
    && apt-get update && apt-get install -y \
        ros-${ROS_DISTRO}-desktop \
        ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
        python3-colcon-common-extensions \
        python3-rosdep \
        python3-vcstool \
        ros-dev-tools \
    && rm -rf /var/lib/apt/lists/* /tmp/ros2-apt-source.deb

# -----------------------------------------------------------------------------
# 4. ONNX Runtime (CPU) — installed to /opt/onnxruntime
# -----------------------------------------------------------------------------
RUN wget -qO /tmp/onnxruntime.tgz \
        "https://github.com/microsoft/onnxruntime/releases/download/v${ONNXRUNTIME_VERSION}/onnxruntime-linux-x64-${ONNXRUNTIME_VERSION}.tgz" \
    && mkdir -p /opt/onnxruntime \
    && tar -xzf /tmp/onnxruntime.tgz -C /opt/onnxruntime --strip-components=1 \
    && rm /tmp/onnxruntime.tgz

# -----------------------------------------------------------------------------
# 5. Python deps (no torch -- not needed for C++ static analysis)
# -----------------------------------------------------------------------------
RUN pip3 install --break-system-packages --ignore-installed \
    opencv-python-headless onnxruntime scikit-learn matplotlib pyyaml

# -----------------------------------------------------------------------------
# 6. Clone autoware_vision_pilot v0.9
# -----------------------------------------------------------------------------
WORKDIR /autoware_ws/src
RUN git clone --recurse-submodules \
        https://github.com/autowarefoundation/autoware_vision_pilot.git \
    && cd autoware_vision_pilot \
    && git checkout v0.9 \
    && git submodule update --init --recursive

# -----------------------------------------------------------------------------
# 7. Symlink ONNX Runtime into the production release source tree
#    (workaround for cmake_install.cmake expecting it in-tree)
# -----------------------------------------------------------------------------
RUN ln -s /opt/onnxruntime \
    /autoware_ws/src/autoware_vision_pilot/VisionPilot/Production_Releases/0.9/onnxruntime

# -----------------------------------------------------------------------------
# 8. rosdep
# -----------------------------------------------------------------------------
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    && rosdep init \
    && rosdep update \
    && rosdep install -y \
        --from-paths /autoware_ws/src \
        --ignore-src \
        --rosdistro ${ROS_DISTRO} \
        --skip-keys "carla ros_carla_msgs ament_python OpenCV onnxruntime" \
        || true

# -----------------------------------------------------------------------------
# 9. Pre-bake build — validates everything compiles cleanly at image build time
# -----------------------------------------------------------------------------
WORKDIR /autoware_ws
RUN . /opt/ros/${ROS_DISTRO}/setup.sh     && colcon build         --base-paths src/autoware_vision_pilot/VisionPilot/Production_Releases/0.9         --symlink-install         --cmake-args             -DCMAKE_BUILD_TYPE=Release             -DCMAKE_C_COMPILER=/usr/bin/clang-${CLANG_VER}             -DCMAKE_CXX_COMPILER=/usr/bin/clang++-${CLANG_VER}         2>&1 | tee /tmp/prebuild.log     && echo "Pre-build successful"

# -----------------------------------------------------------------------------
# 10. Entrypoint — cleans build, reruns under kwinject at container start
# -----------------------------------------------------------------------------
RUN mkdir -p /artifacts

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /autoware_ws
ENTRYPOINT ["/entrypoint.sh"]