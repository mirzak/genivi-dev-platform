SRC_URI = "git://github.com/GENIVI/hmi-layout-gdp.git"
SRCREV = "95aadfb33d95e14030585c3fa2e1afb0e7b743c8"
LICENSE  = "MPL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9741c346eef56131163e13b9db1241b3"

DEPENDS = "dbus-c++ systemd wayland-ivi-extension qtquick1 qtdeclarative qtbase ivi-logging"

RDEPENDS_${PN} += "qtbase qtsvg"

S = "${WORKDIR}/git"

inherit autotools pkgconfig qmake5 systemd

SYSTEMD_AUTO_ENABLE = "enable"

SRC_URI_append ="\
    file://gdp-new-hmi.service \
    "

FILES_${PN} += "\
    ${libdir}/* \
    /opt/gdp-hmi/bin/gdp-hmi \
    /usr/share/applications/* \
    ${systemd_user_unitdir} \
"

do_install_append() {
    install -d ${D}${systemd_user_unitdir}
    install -p -D ${WORKDIR}/gdp-new-hmi.service ${D}${systemd_user_unitdir}/gdp-new-hmi.service
    install -d ${D}${sysconfdir}/systemd/user/default.target.wants
    ln -sf ${systemd_user_unitdir}/gdp-new-hmi.service ${D}${sysconfdir}/systemd/user/default.target.wants
}
