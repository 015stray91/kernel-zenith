## [Magisk & KernelSU] [nethunter] [This is standalone script, not sourced]
##
## REF: ./nethunter/META-INF/com/google/android/update-recovery:get_bb() & $MAGISKBB
##      ./nethunter/post-fs-data.sh
##      ./nethunter/tools/install-chroot.sh

MODDIR="${0%/*}"

## KernelSU Next with a metamodule (e.g. meta-overlayfs): module content is
## served from an ext4 image that is populated at INSTALL time (metainstall.sh
## copies $MODPATH/system into it) and this script runs BEFORE that image is
## mounted at boot, so anything written here would never reach the overlay.
## The BusyBox applet farm is generated in customize.sh instead; nothing to do.
## Plain Magisk and plain KernelSU mount $MODDIR/system directly, so the
## runtime generation below stays for them.
[ -L /data/adb/metamodule ] && exit 0

TARGET=$MODDIR/system
BIN=$TARGET/bin

if [ -d /system/xbin ]; then
  XBIN=$TARGET/xbin
else
  XBIN=$TARGET/bin
fi

[ -d "$XBIN" ] || exit 0

rm -f $XBIN/busybox_nh
cd $XBIN/
## Pick the highest busybox_nh-* version. 'ls -v' (version sort) is a GNU
## extension - toybox ls rejects it, so sort numerically on the major version
## instead (works everywhere).
busybox_nh=$(ls busybox_nh-* 2>/dev/null | sort -t- -k3 -n | tail -n 1)
[ -z "$busybox_nh" ] && exit 1
#BB=$XBIN/$busybox_nh # Use NetHunter BusyBox from ./arch/<arch>/tools/ # Alt: export BB=$TMP/$busybox_nh
ln -sf $XBIN/$busybox_nh busybox_nh # Alt: $XBIN/$busybox_nh ln -sf $busybox_nh busybox_nh

## Create symlink for applets
sysbin="$(ls /system/bin)"
existbin="$(ls $BIN 2>/dev/null || true)"
for applet in $($XBIN/busybox_nh --list); do
  case $XBIN in
    */bin)
      if [ "$(echo "$sysbin" | $XBIN/busybox_nh grep "^$applet$")" ]; then
        if [ "$(echo "$existbin" | $XBIN/busybox_nh grep "^$applet$")" ]; then
          $XBIN/busybox_nh ln -sf busybox_nh $applet
        fi
      else
        $XBIN/busybox_nh ln -sf busybox_nh $applet
      fi
      ;;
    *) $XBIN/busybox_nh ln -sf busybox_nh $applet
      ;;
    esac
done

[ -e $XBIN/busybox ] || {
  ln -s $XBIN/busybox_nh $XBIN/busybox # Alt: $XBIN/$busybox_nh ln -sf busybox_nh busybox
}

chmod 755 *
chcon u:object_r:system_file:s0 *

exit 0
