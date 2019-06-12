#include <QCoreApplication>
#include <QThread>
#include "csoundengine.h"


int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    // prepare replica
    QSharedPointer<ControlDeskReplica> ptr; // shared pointer to hold source replica
    QRemoteObjectNode repNode; // create remote object node
    repNode.connectToNode(QUrl(QStringLiteral("local:controlDesk"))); // connect with remote host node
    ptr.reset(repNode.acquire<ControlDeskReplica>()); // acquire replica of source from host node

    // create Csound and put it into a thread
    QThread * csoundThread = new QThread();
    CsoundEngine * cs = new CsoundEngine(ptr);
    cs->moveToThread(csoundThread);


    QObject::connect(csoundThread, &QThread::finished, cs, &CsoundEngine::deleteLater);
    QObject::connect(csoundThread, &QThread::finished, csoundThread, &QThread::deleteLater); // somehow exiting from Csound is not clear yet, the thread gets destoyed when Csoun is still running.
	//connect(QApplication::instance(), QApplication::aboutToQuit,cs,&CsoundEngine::stop );

    csoundThread->start();
	//cs->play("/home/tarmo/tarmo/csound/cs-lugu.csd");

    return a.exec();
}
