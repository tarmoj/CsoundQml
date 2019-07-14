QT += quick core remoteobjects widgets
android: QT += androidextras
CONFIG += c++11

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
    controldesk.cpp

HEADERS += \
    controldesk.h \


RESOURCES += qml.qrc

DISTFILES += \
	controldesk.rep

REPC_SOURCE = controldesk.rep # TODO: find out how to have one rep file, not two

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# INSTALL RULES -----

linux:!android: {
INSTALL_PATH= $$PWD/../bin
target.path += $$INSTALL_PATH
INSTALLS += target
}

#NB! uuri, kas unix:documentation.extra = create_docs; mv master.doc toc.doc extra -  oleks kasulik!

macx {
	first.path = $$PWD/../bin
	first.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD # deployment

        second.path = $$PWD/../bin
        second.commands = install_name_tool -add_rpath "@executable_path/../Frameworks/"  $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/engine

        third.path = $$PWD/../bin
        third.commands = install_name_tool -change  @rpath/CsoundLib64.framework/Versions/6.0/CsoundLib64 CsoundLib64.framework/Versions/6.0/CsoundLib64 $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/engine

	final.path = $$PWD
	final.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD -dmg# deployment BETTER: use hdi-util

	#TODO: check the dependcies of engine, set name_path of engine binariy (use Csound64 from system)

        INSTALLS += first second third #final

}

win32 {
	first.path = $$PWD/../bin
	first.commands = $$[QT_INSTALL_PREFIX]/bin/windeployqt  -qmldir=$$PWD  $$OUT_PWD/$$DESTDIR/$${TARGET}.exe # first deployment
	INSTALLS += first
}

