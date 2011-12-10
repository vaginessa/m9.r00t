#!/system/bin/sh -x

BASEDIR="/data/data/ru.meizu.m9.r00t/files"

test -x /system/bin/su
if [ "$?" == 0 ] ; then 
    echo "already r00ted"
    exit 0
fi

echo "running from uid 0..."

echo "prepare busybox and su..."
chmod 4755 "$BASEDIR"/busybox
chmod 4755 "$BASEDIR"/su

echo "store original /system/bin to new path..."
"$BASEDIR"/busybox mkdir -p "$BASEDIR"/system/bin
"$BASEDIR"/busybox mount -o bind /system/bin "$BASEDIR"/system/bin


echo "mount /system/bin into memory..."
"$BASEDIR"/busybox mount -t tmpfs none /system/bin

echo "link original /system/bin content to new location..."
"$BASEDIR"/busybox ln -s "$BASEDIR"/system/bin/* /system/bin/


echo "installing busybox and su..."
"$BASEDIR"/busybox --install -s /system/bin
"$BASEDIR"/busybox cp "$BASEDIR"/su /system/bin/su

echo "check adfree files in /data..." 
test -f /data/data/hosts
if [ "$?" == 0 ] ; then
    echo "store original /system/etc to new path..."
    "$BASEDIR"/busybox mkdir -p "$BASEDIR"/system/etc
    "$BASEDIR"/busybox mount -o bind /system/bin "$BASEDIR"/system/etc

    echo "mount /system/etc into memory..."
    "$BASEDIR"/busybox mount -t tmpfs none /system/etc

    echo "link original /system/etc content to new location..."
    "$BASEDIR"/busybox ln -s "$BASEDIR"/system/etc/* /system/etc/

    "$BASEDIR"/busybox ln -s /data/data/hosts /system/etc/
    echo "change system /etc/hosts to adfree version..."
else
    echo "adfree is not installed or not configured properly."
fi

echo "check fonts replacement directory..."
if [ $(find /data/local/fonts -iname '*.ttf' 2>/dev/null | wc -l) -gt 0 ] ; then
    echo "safely replace system fonts..."
    "$BASEDIR"/busybox mkdir -p "$BASEDIR"/system/fonts
    "$BASEDIR"/busybox mount -o bind /system/fonts "$BASEDIR"/system/fonts
    "$BASEDIR"/busybox mount -t tmpfs none /system/fonts
    "$BASEDIR"/busybox ln -s "$BASEDIR"/system/fonts/* /system/fonts/
    for FONT in $(find /data/local/fonts -iname '*.ttf') ; do
        "$BASEDIR"/busybox ln -s "$FONT" /system/fonts/
    done
else
    echo "use default system fonts..."
fi

if [ "$?" == 0 ] ; then
    echo "done. now you have temporary root rights."
else
    echo "oops, something wrong."
fi
