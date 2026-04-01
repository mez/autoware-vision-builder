# This file will be configured to contain variables for CPack. These variables
# should be set in the CMake list file of the project before CPack module is
# included. The list of available CPACK_xxx variables and their associated
# documentation may be obtained using
#  cpack --help-variable-list
#
# Some variables are common to all generators (e.g. CPACK_PACKAGE_NAME)
# and some are specific to a generator
# (e.g. CPACK_NSIS_EXTRA_INSTALL_COMMANDS). The generator specific variables
# usually begin with CPACK_<GENNAME>_xxxx.


set(CPACK_BUILD_SOURCE_DIRS "/autoware_ws/src/autoware_vision_pilot/VisionPilot/Production_Releases/0.9;/autoware_ws/build/visionpilot")
set(CPACK_CMAKE_GENERATOR "Unix Makefiles")
set(CPACK_COMPONENT_UNSPECIFIED_HIDDEN "TRUE")
set(CPACK_COMPONENT_UNSPECIFIED_REQUIRED "TRUE")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "cuda-toolkit-12-6,
        libcudnn9-cuda-12,
        libcublaslt11,
        libcudart11.0,
        libnvinfer10,
        libnvinfer-plugin10,
        libnvonnxparsers10,
        cuda-drivers")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "atanasko.mitrev@autoware.org, tran.huy@autoware.org, pranav.doma@autoware.org")
set(CPACK_DEFAULT_PACKAGE_DESCRIPTION_FILE "/usr/share/cmake-3.28/Templates/CPack.GenericDescription.txt")
set(CPACK_DEFAULT_PACKAGE_DESCRIPTION_SUMMARY "visionpilot built using CMake")
set(CPACK_GENERATOR "DEB")
set(CPACK_INNOSETUP_ARCHITECTURE "x64")
set(CPACK_INSTALL_CMAKE_PROJECTS "/autoware_ws/build/visionpilot;visionpilot;ALL;/")
set(CPACK_INSTALL_PREFIX "/autoware_ws/install/visionpilot")
set(CPACK_MODULE_PATH "")
set(CPACK_NSIS_DISPLAY_NAME "visionpilot 0.5")
set(CPACK_NSIS_INSTALLER_ICON_CODE "")
set(CPACK_NSIS_INSTALLER_MUI_ICON_CODE "")
set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES")
set(CPACK_NSIS_PACKAGE_NAME "visionpilot 0.5")
set(CPACK_NSIS_UNINSTALL_NAME "Uninstall")
set(CPACK_OBJCOPY_EXECUTABLE "/usr/bin/llvm-objcopy-20")
set(CPACK_OBJDUMP_EXECUTABLE "/usr/bin/llvm-objdump-20")
set(CPACK_OUTPUT_CONFIG_FILE "/autoware_ws/build/visionpilot/CPackConfig.cmake")
set(CPACK_PACKAGE_CONTACT "")
set(CPACK_PACKAGE_DEFAULT_LOCATION "/")
set(CPACK_PACKAGE_DESCRIPTION_FILE "/usr/share/cmake-3.28/Templates/CPack.GenericDescription.txt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "VisionPilot v0.5")
set(CPACK_PACKAGE_FILE_NAME "visionpilot-0.5-x86_64")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "visionpilot 0.5")
set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "visionpilot 0.5")
set(CPACK_PACKAGE_NAME "visionpilot")
set(CPACK_PACKAGE_RELOCATABLE "true")
set(CPACK_PACKAGE_VENDOR "Autoware Foundation")
set(CPACK_PACKAGE_VERSION "0.5")
set(CPACK_PACKAGE_VERSION_MAJOR "0")
set(CPACK_PACKAGE_VERSION_MINOR "5")
set(CPACK_READELF_EXECUTABLE "/usr/bin/llvm-readelf-20")
set(CPACK_RESOURCE_FILE_LICENSE "/usr/share/cmake-3.28/Templates/CPack.GenericLicense.txt")
set(CPACK_RESOURCE_FILE_README "/usr/share/cmake-3.28/Templates/CPack.GenericDescription.txt")
set(CPACK_RESOURCE_FILE_WELCOME "/usr/share/cmake-3.28/Templates/CPack.GenericWelcome.txt")
set(CPACK_SET_DESTDIR "OFF")
set(CPACK_SOURCE_GENERATOR "TBZ2;TGZ;TXZ;TZ")
set(CPACK_SOURCE_OUTPUT_CONFIG_FILE "/autoware_ws/build/visionpilot/CPackSourceConfig.cmake")
set(CPACK_SOURCE_RPM "OFF")
set(CPACK_SOURCE_TBZ2 "ON")
set(CPACK_SOURCE_TGZ "ON")
set(CPACK_SOURCE_TXZ "ON")
set(CPACK_SOURCE_TZ "ON")
set(CPACK_SOURCE_ZIP "OFF")
set(CPACK_SYSTEM_NAME "x86_64")
set(CPACK_THREADS "1")
set(CPACK_TOPLEVEL_TAG "x86_64")
set(CPACK_WIX_SIZEOF_VOID_P "8")

if(NOT CPACK_PROPERTIES_FILE)
  set(CPACK_PROPERTIES_FILE "/autoware_ws/build/visionpilot/CPackProperties.cmake")
endif()

if(EXISTS ${CPACK_PROPERTIES_FILE})
  include(${CPACK_PROPERTIES_FILE})
endif()
