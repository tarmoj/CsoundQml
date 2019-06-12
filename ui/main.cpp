#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "controldesk.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    ControlDesk controlDesk;
    engine.rootContext()->setContextProperty("controlDesk", &controlDesk);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty()) {
        return -1;
	}

	// connect QML signals to source objects signals
	QObject *ui = engine.rootObjects().first();
	QObject::connect(ui, SIGNAL(play(QString)), &controlDesk, SIGNAL(compileCsdText(QString))  ); // TODO change singal to play(), too
	QObject::connect(ui, SIGNAL(stop()), &controlDesk, SIGNAL(stop())  );
	QObject::connect(ui, SIGNAL(newControlChannelValue(QString, double) ), &controlDesk, SIGNAL(newControlChannelValue(QString, double))  );
	QObject::connect(ui, SIGNAL(newStringChannelValue(QString, QString) ), &controlDesk, SIGNAL(newStringChannelValue(QString, QString))  );
	QObject::connect(ui, SIGNAL(crash()), &controlDesk, SIGNAL(crash())  );

	// set source node
	 QRemoteObjectHost srcNode(QUrl(QStringLiteral("local:controlDesk")));
     srcNode.enableRemoting(&controlDesk); // enable remoting/sharing

    return app.exec();
}
