FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

WESTONTTY ??= "1"
WESTONUSER ??= "display"
WESTONGROUP ??= "display"
WESTONARGS ?= "--idle-time=0  --tty=${WESTONTTY}"
DISPLAY_XDG_RUNTIME_DIR ??= "/run/platform/${WESTONUSER}"

WESTONSTART ??= "/usr/bin/weston ${WESTONARGS}"
WESTONSTART_append = " ${@bb.utils.contains("IMAGE_FEATURES", "debug-tweaks", " --log=${DISPLAY_XDG_RUNTIME_DIR}/weston.log", "",d)}"

SRC_URI += " \
    file://weston_tmpfiles.conf \
    file://weston.service.add \
"

do_install_append() {
    sed -i "/\[Unit\]/aConflicts=getty@tty${WESTONTTY}.service" \
           ${D}${systemd_system_unitdir}/weston.service

    sed -i "/\[Service\]/r ${S}/weston.service.add" \
           ${D}${systemd_system_unitdir}/weston.service

    if ! grep -q '^Group=' ${D}${systemd_system_unitdir}/weston.service; then
        sed -i "/\[Service\]/aGroup=root" ${D}${systemd_system_unitdir}/weston.service
    fi
    if ! grep -q '^User=' ${D}${systemd_system_unitdir}/weston.service; then
        sed -i "/\[Service\]/aUser=root" ${D}${systemd_system_unitdir}/weston.service
    fi

    sed -e 's,User=root,User=${WESTONUSER},g' \
        -e 's,Group=root,Group=${WESTONGROUP},g' \
        -e 's,ExecStart=.*,ExecStart=${WESTONSTART},g' \
        -e 's,@WESTONTTY@,${WESTONTTY},g' \
        -e 's,@XDG_RUNTIME_DIR@,${DISPLAY_XDG_RUNTIME_DIR},g' \
        -i ${D}${systemd_system_unitdir}/weston.service

    install -d ${D}${sysconfdir}/udev/rules.d
    cat >${D}${sysconfdir}/udev/rules.d/zz-dri.rules <<'EOF'
SUBSYSTEM=="drm", MODE="0660", GROUP="${WESTONGROUP}", TAG+="systemd", ENV{SYSTEMD_WANTS}="weston.service"
EOF

    # user 'display' must own /dev/tty${WESTONTTY} for weston to start correctly
    cat >${D}${sysconfdir}/udev/rules.d/zz-tty.rules <<'EOF'
SUBSYSTEM=="tty", KERNEL=="tty${WESTONTTY}", OWNER="${WESTONUSER}", TAG+="systemd", ENV{SYSTEMD_WANTS}="weston.service"
EOF

    # user 'display' must also be able to access /dev/input/*
    cat >${D}${sysconfdir}/udev/rules.d/zz-input.rules <<'EOF'
SUBSYSTEM=="input", MODE="0660", GROUP="input", TAG+="systemd", ENV{SYSTEMD_WANTS}="weston.service"
EOF

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -Dm755 ${WORKDIR}/weston_tmpfiles.conf ${D}/${libdir}/tmpfiles.d/weston.conf

    sed -e 's,@WESTONUSER@,${WESTONUSER},g' \
        -e 's,@WESTONGROUP@,${WESTONGROUP},g' \
        -i ${D}/${libdir}/tmpfiles.d/weston.conf
}

FILES_${PN} += "${libdir}/tmpfiles.d/*.conf"
