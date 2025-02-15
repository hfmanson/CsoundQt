#!/bin/bash

# Script to make AppImage (all-included binary) for 64 bit linux
# ecperimental
# option to include Also Csound and Csound manual


# change according to your own sysem
# constants

BINARY="CsoundQt-d-cs6"
BUILD_DIR="../../build-qcs-Desktop-Release/"
EXECUTABLE="$BUILD_DIR/bin/$BINARY"
VERSION="0.9.8.2"
CSOUND_VERSION="6.14.0"
CSOUND_PREFIX="/usr/local/"
CSOUND_PLUGINS_DIR="$CSOUND_PREFIX/lib/csound/plugins64-6.0/" 
CSOUND_MANUAL_HTML_DIR="$HOME/src/csound-manual/html"
BUNDLE_CSOUND=true # for now: always bundle Csound
SRC_DIR="../" #CsoundQt root
LIB_DIR="/usr/lib/"
APP_DIR="AppDir" #"$BUILD_DIR/AppDir"



# download linuxdeploy and its Qt plugin
#in my case they are installed in path already
#wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
#wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage


LINUXDEPLOY="$HOME/bin/linuxdeploy-x86_64.AppImage"


#1 export necessary environment variables
export VERSION=0.9.8.2 
export QML_SOURCES_PATHS="$SRC_DIR/src/QML"; 


# correct desktop file -  instead of csoundqt as command use the actual binary name
sed "s/Exec=csoundqt/Exec=$BINARY/g" $SRC_DIR/csoundqt.desktop > csoundqt.desktop

#2 create initial AppDir with linuxdeploy
#TODO: cannot blacklist csound libs.blacklist nor -blacklist flag work...
$LINUXDEPLOY --appdir $APP_DIR --executable=$EXECUTABLE --desktop-file=csoundqt.desktop --icon-file=$SRC_DIR/images/csoundqt.svg --library=$LIB_DIR/libportmidi.so --library=$LIB_DIR/x86_64-linux-gnu/liblo.so --library=$LIB_DIR/x86_64-linux-gnu/libstk.so   --plugin=qt


#libraries still missing: libstk-4.5.0.so libfltk.so.1.1


# copy Examples and templates
mkdir -p  $APP_DIR/usr/share/csoundqt/
cp -r $SRC_DIR/src/Examples  $APP_DIR/usr/share/csoundqt
cp -r $SRC_DIR/templates  $APP_DIR/usr/share/csoundqt


# copy Csound binary, plugins and and Csound Manual
mkdir -p  $APP_DIR/usr/lib/csound
cp -r $CSOUND_PLUGINS_DIR $APP_DIR/usr/lib/csound
mkdir -p $APP_DIR/usr/share/doc/csound-doc/
cp -r $CSOUND_MANUAL_HTML_DIR $APP_DIR/usr/share/doc/csound-doc/
cp "$CSOUND_PREFIX/bin/csound" $APP_DIR/usr/bin
#what about other utilities? Should they be accessible? I think no, then user has to install csound separately. NB! Try to match the Csound version!

#create hook to set Csound Plugins Dir environment
echo 'export OPCODE6DIR64="${APPDIR}/usr/lib/csound/plugins64-6.0/"' >  $APP_DIR/apprun-hooks/csound-plugins-hook.sh


# and create final AppImage
$LINUXDEPLOY --appdir $APP_DIR  --output appimage


