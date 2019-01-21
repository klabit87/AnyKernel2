# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=klabit Kernel for the Samsung Galaxy S9+ by @klabit87
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=star2qlte
device.name2=star2qltexx
device.name3=star2qltezh
device.name4=star2qltechn
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


# Print message and exit
die() {
  ui_print " "; ui_print "$*";
  exit 1;
}

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

## Begin ramdisk changes
ui_print "Patching ramdisk to fake official status...";
backup_file init.rc;
insert_line init.rc "init.services.rc" after "import /init.usb.configfs.rc" "import /init.services.rc";



# Warn user of their support status
#android_version="$(file_getprop /system/build.prop "ro.build.version.release")";
#security_patch="$(file_getprop /system/build.prop "ro.build.version.security_patch")";
#case "$android_version:$security_patch" in
#  "9:2018-11-05") support_status="a supported";;
#  "8.1.0"*|"P"*|"9"*) support_status="an unsupported";;
#  *) die "Completely unsupported OS configuration!";;
#esac;
#ui_print " "; ui_print "You are on $android_version with the $security_patch security patch level! This is $support_status configuration...";


# If the kernel image and dtbs are separated in the zip
decompressed_image=/tmp/anykernel/kernel/Image
compressed_image=$decompressed_image.gz
ui_print " "; ui_print "Magisk detected! Patching kernel so reflashing Magisk is not necessary...";
if [ -f $compressed_image ]; then
  # Hexpatch the kernel if Magisk is installed ('skip_initramfs' -> 'want_initramfs')
  if [ -d $ramdisk/.backup ]; then
    $bin/magiskboot --decompress $compressed_image $decompressed_image;
    $bin/magiskboot --hexpatch $decompressed_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300;
    $bin/magiskboot --compress=gzip $decompressed_image $compressed_image;
  fi;
fi;

# Install the boot image
write_boot;
