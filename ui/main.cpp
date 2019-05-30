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
    if (engine.rootObjects().isEmpty())
        return -1;



     QRemoteObjectHost srcNode(QUrl(QStringLiteral("local:controlDesk"))); // create host node without Registry
     srcNode.enableRemoting(&controlDesk); // enable remoting/sharing

    return app.exec();
}
