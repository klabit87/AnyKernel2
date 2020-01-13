# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=klabit Kernel for the Samsung Galaxy Note 9 by @klabit87
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=crownqlte
device.name2=crownqltexx
device.name3=crownqltezh
device.name4=crownqltechn
'; } # end properties

# shell variables
block=/dev/block/platform/soc/1d84000.ufshc/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

# begin ramdisk changes

# Ramdisk changes - Set split_img OSLevel depending on ROM
(grep -w ro.build.version.security_patch | cut -d= -f2) </system/build.prop > /tmp/rom_oslevel
ROM_OSLEVEL=`cat /tmp/rom_oslevel`
echo $ROM_OSLEVEL | rev | cut -c4- | rev > /tmp/rom_oslevel
ROM_OSLEVEL=`cat /tmp/rom_oslevel`
ui_print "- Setting security patch level to $ROM_OSLEVEL"
echo $ROM_OSLEVEL > $split_img/boot.img-oslevel

# Warn user of their support status
android_version="$(file_getprop /system/build.prop "ro.build.version.release")";
#security_patch="$(file_getprop /system/build.prop "ro.build.version.security_patch")";
case "$android_version:$security_patch" in
  "10") support_status="a supported";;
  "9") support_status="a supported";;
  "8.1.0") support_status="an unsupported";;
  *) die "Completely unsupported OS configuration!";;
esac;
ui_print " "; ui_print "You are on $android_version ! This is $support_status configuration...";

# If the kernel image and dtbs are separated in the zip
decompressed_image=/tmp/anykernel/kernel/Image
compressed_image=$decompressed_image.gz
# ui_print " "; ui_print "Magisk detected! Patching kernel so reflashing Magisk is not necessary...";
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
## end install

