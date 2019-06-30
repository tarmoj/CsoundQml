QT -= gui
QT += core remoteobjects

CONFIG += c++11 console
CONFIG -= app_bundle

TEMPLATE = app

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
    csoundengine.cpp

HEADERS += \
    csoundengine.h \

DISTFILES += \
	controldesk.rep

REPC_REPLICA = controldesk.rep

linux|android: INCLUDEPATH += /usr/local/include/csound
win32: INCLUDEPATH += "C:/Program Files/Csound6_x64/include/csound"
mac: INCLUDEPATH += /Library/Frameworks/CsoundLib64.framework/Headers


win32-msvc: LIBS += -L"C:/Program Files/Csound6_x64/bin csound64.lib"
linux:!android: LIBS += -lcsound64

mac: {
LIBS += -F/Library/Frameworks/ -framework CsoundLib64
INCLUDEPATH += /Library/Frameworks/CsoundLib64.framework/Versions/6.0/Headers
}


android {
  QT += androidextras
  INCLUDEPATH += /home/tarmo/src/csound6-git/Android/CsoundAndroid/jni/	 #TODO: should have an extra varaible, not hardcoded personal library
  HEADERS += AndroidCsound.hpp
  LIBS +=  -L/home/tarmo/src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi-v7a/ -lcsoundandroid -lsndfile -lc++_shared -loboe
}



linux:!android:: QMAKE_POST_LINK += $$quote(cp $$OUT_PWD/$$TARGET $$OUT_PWD/../ui) # to put the binaries in the same folder
#mac reuire

macx: QMAKE_POST_LINK += $$quote(cp $$OUT_PWD/$$TARGET.app/Contents/MacOS/$$TARGET $$OUT_PWD/../ui.app/Contents/MacOS)

win32: QMAKE_POST_LINK += $$quote(cmd /c copy /y $$OUT_PWD/$$TARGET $$OUT_PWD/../ui)

# install rules by engine since this is built later

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/../../../../../src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi-v7a/libc++_shared.so \
        $$PWD/../../../../../src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi-v7a/libcsoundandroid.so \
        $$PWD/../../../../../src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi-v7a/liboboe.so \
        $$PWD/../../../../../src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi-v7a/libsndfile.so
}


