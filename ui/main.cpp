#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "controldesk.h"

#ifdef Q_OS_ANDROID

#include <QtAndroidExtras/QtAndroid>

bool checkPermission() { // requires >= Qt 5.10
	QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
	if(r == QtAndroid::PermissionResult::Denied) {
		QtAndroid::requestPermissionsSync( QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE" );
		r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
		if(r == QtAndroid::PermissionResult::Denied) {
			 return false;
		}
   }
   return true;
}
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

	QApplication app(argc, argv);

#ifdef Q_OS_ANDROID
	checkPermission();
#endif

    QQmlApplicationEngine engine;
    ControlDesk controlDesk;
    engine.rootContext()->setContextProperty("csound", &controlDesk); // to make usage more familiar and similar to usual Csound API
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty()) {
        return -1;
	}

//	// connect QML signals to source objects signals
//	QObject *ui = engine.rootObjects().first();
//	QObject::connect(ui, SIGNAL(play(QString)), &controlDesk, SIGNAL(compileCsdText(QString))  ); // TODO change singal to play(), too
//	QObject::connect(ui, SIGNAL(stop()), &controlDesk, SIGNAL(stop())  );
//	QObject::connect(ui, SIGNAL(newControlChannelValue(QString, double) ), &controlDesk, SIGNAL(newControlChannelValue(QString, double))  );
//	QObject::connect(ui, SIGNAL(newStringChannelValue(QString, QString) ), &controlDesk, SIGNAL(newStringChannelValue(QString, QString))  );
//	QObject::connect(ui, SIGNAL(crash()), &controlDesk, SIGNAL(crash())  );
//	QObject::connect(ui, SIGNAL(requestChannelValue(QString)), &controlDesk, SIGNAL(requestChannelValue(QString))  );

	// set source node

     QRemoteObjectHost srcNode(QUrl(QStringLiteral("local:controlDesk"))); // tcp://192.168.1.130

     srcNode.enableRemoting(&controlDesk); // enable remoting/sharing

    return app.exec();
}
