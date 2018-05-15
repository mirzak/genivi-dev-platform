FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = "\
    file://GDP_AM_Button.png \
    file://GDP_Background.png \
    file://GDP_Browser_Button.png \
    file://weston.ini \
    file://0001-Allow-regular-users-to-launch-Weston_2.0.0.patch \
"

RDEPENDS_${PN}_append_qemux86 = " mesa-megadriver"
RDEPENDS_${PN}_append_qemux86-64 = " mesa-megadriver"
RDEPENDS_${PN}_append_vexpressa9 = " mesa-megadriver"

EXTRA_OECONF_remove_qemux86-64 = "\
    WESTON_NATIVE_BACKEND=fbdev-backend.so \
"

EXTRA_OECONF_append_qemux86-64 = "\
    WESTON_NATIVE_BACKEND=drm-backend.so \
"

EXTRA_OECONF_append_vexpressa9 = " WESTON_NATIVE_BACKEND=fbdev-backend.so"

EXTRA_OECONF_append_rpi = "\
    WESTON_NATIVE_BACKEND=drm-backend.so \
    --disable-static \
"

CFLAGS_append_rpi ="\
    -I${STAGING_DIR_TARGET}/usr/include/interface/vcos/pthreads \
    -I${STAGING_DIR_TARGET}/usr/include/interface/vmcs_host/linux \
"

do_install_append() {
    install -d ${D}/usr/share/weston
    install -m 644 ${WORKDIR}/GDP*.png ${D}/usr/share/weston

    install -d ${D}${sysconfdir}/xdg/weston
    install -m 0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston/weston.ini
}

CONFFILES_${PN} += "${sysconfdir}/xdg/weston/weston.ini"

EXTRA_OECONF_append = " --enable-sys-uid"
