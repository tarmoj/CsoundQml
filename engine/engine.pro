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
linux:!android: -lcsound64

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

#---- install rules
linux:!android: {
INSTALL_PATH= $$PWD/../bin
target.path += $$INSTALL_PATH
INSTALLS += target
}

macx {
	first.path = $$PWD/../bin
	first.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD # deployment

	#second.path = $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks
	#second.files = /Library/Frameworks/CsoundLib64.framework
	#second.commands = rm -rf $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/CsoundLib64.framework/
	#TODO: remove Resources Java, Luajit, Manual, Opcodes64 enamus...  PD, Python, samples
	# remove lbCsoundAc, võibolla libcsnd6

	third.path = $$PWD
	third.commands = install_name_tool -change @rpath/CsoundLib64.framework/Versions/6.0/CsoundLib64 CsoundLib64.framework/Versions/6.0/CsoundLib64  $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/engine

	final.path = $$PWD
	final.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD -dmg# deployment BETTER: use hdi-util


	INSTALLS += first third  #final

}

win32 {
	first.path = $$PWD/../bin
	first.commands = $$[QT_INSTALL_PREFIX]/bin/windeployqt  $$OUT_PWD/$$DESTDIR/$${TARGET}.exe # first deployment
	INSTALLS += first
}



