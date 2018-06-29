include local.inc

GPU_MEM = "128"

MACHINE_FEATURES_append = " vc4graphics"

MULTI_PROVIDER_WHITELIST += "virtual/libgl virtual/egl virtual/libgles1 virtual/libgles2"

require conf/distro/sota.conf.inc

# If credentials are not provided to the aktualizr application it will fail
# to start and the systemd service will keep retrying, polluting our logs.
#
# aktualizr is disabled by default for this reason.
#
# To activate, provide the appropriate credentials in SOTA_PACKED_CREDENTIALS
# and comment/remove the line that disables the aktualizr systemd service.
#
# Details about this can be found here:
#     https://github.com/advancedtelematic/meta-updater#sota-related-variables-in-local-conf

#SOTA_PACKED_CREDENTIALS = "<path to credentials>"
SYSTEMD_AUTO_ENABLE_pn-aktualizr = "disable"
