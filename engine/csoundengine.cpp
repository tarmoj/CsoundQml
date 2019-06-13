#include "csoundengine.h"
#include <QDebug>
#include <QCoreApplication>
#include <QThread>

// remoteobject stuff:
#include <QSharedPointer>
#include <QRemoteObjectNode>
//#include <qremoteobjectdynamicreplica.h>


CsoundEngine::CsoundEngine(QSharedPointer<ControlDeskReplica> ptr, QObject *parent) : QObject(parent),
    reptr(ptr)
{
	stopNow = false; // TODO: style -  initalize in class definition
	isRunning = false;
	cs = nullptr;
	heartBeatTimer = new QTimer(this);

    initConnections();

}

CsoundEngine::~CsoundEngine()
{

}

void CsoundEngine::initConnections()
{
	heartBeatTimer->start(1000);
	connect(heartBeatTimer, SIGNAL(timeout()), this, SLOT(timerSlot())  );

	connect(this, SIGNAL(newHeartBeat()), reptr.data(), SLOT(heartBeat())   );
	connect(this, SIGNAL(newCsoundMessage(QString)), reptr.data(), SLOT(handleCsoundMessage(QString))   );
	connect(this, SIGNAL(newEngineState(int) ), reptr.data(), SLOT(setEngineState(int))   );
	connect(this, SIGNAL(newChannelValue(QString, double) ), reptr.data(), SLOT(receiveChannelValue(QString, double) )   );

	connect(reptr.data(), SIGNAL(compileCsdText(QString)), this, SLOT(play(QString)));

	connect(reptr.data(), SIGNAL(stop()), this, SLOT(stop()) );
	connect(reptr.data(), SIGNAL(newControlChannelValue(QString, double) ), this, SLOT(setChannel(QString, double))  );
	connect(reptr.data(), SIGNAL(crash()), this, SLOT(crash()) );
	connect(reptr.data(), SIGNAL(requestChannelValue(QString)), this, SLOT(handleChannelRequest(QString) ) );




}



void CsoundEngine::play(QString csdText) {
#ifdef Q_OS_ANDROID
	cs = new AndroidCsound();
#else
	cs = new Csound();
#endif
    // set options
//    QString csoundOptions= "-odac -d";

//    foreach (QString option, csoundOptions.split(" ")) {
//        qDebug()<<"Setting Csound option: " << option;
//        cs->SetOption(option.toLocal8Bit().data());
//    }

	// must check here, if it is already running. stop if is running. Think, see CsoundQT and test....
	QString message;
    cs->CreateMessageBuffer(0); // also to stdout for debugging


	int result = cs->CompileCsdText(csdText.toLocal8Bit());//cs->CompileCsd(csd.toLocal8Bit());

	while (cs->GetMessageCnt()>0) { // HOW to get error message here?
        message += QString(cs->GetFirstMessage()).simplified() + "\n";
        qDebug()<< message;
		emit newCsoundMessage(message);
		cs->PopFirstMessage();
	}
	if (!message.isEmpty()) {
		emit newCsoundMessage(message.trimmed());
	}

    cs->Start();

    if (!result ) {
		isRunning = true;
		emit newEngineState(PLAYING);

		while (cs->PerformKsmps()==0 && !stopNow) {

			if (cs->GetMessageCnt()>0) {
                message = QString(cs->GetFirstMessage());
                qDebug()<< message;
				emit newCsoundMessage(message.trimmed());
				cs->PopFirstMessage();
			}

			QCoreApplication::processEvents(); // probably bad solution but works. otherwise other slots will never be called
		}
		qDebug()<<"Stopping csound";
		cs->Stop();
		emit newEngineState(STOPPED);

	} else {
		qDebug()<<"Could not compile csdText";
	}
	cs->DestroyMessageBuffer();
	delete cs;
	cs = nullptr;
	stopNow = false;
	isRunning = false;
}

void CsoundEngine::stop() {
    if (isRunning) {
		stopNow = true;
    }
    else {
        qDebug()<<"Csound Engine was not running!";
    }
}

void CsoundEngine::pause()
{

}

void CsoundEngine::setChannel(QString channel, double value) {
	//qDebug()<<"channel: "<<channel << " value: "<<value;
	if (cs) // check if created
		cs->SetChannel(channel.toLocal8Bit(),value);
}


double CsoundEngine::getChannel(QString channel)
{
	if (cs) {
		double value = cs->GetChannel(channel.toLocal8Bit()); // value is
		return value;
	} else
		return -1;
}

QString CsoundEngine::getStringChannel(QString channel)
{
    if (cs) {
        char string[2048]; // to assume the message is not longer...
        cs->GetStringChannel(channel.toLocal8Bit(),string);
        return QString(string);
    } else
        return QString();

}



void CsoundEngine::scoreEvent(QString event)
{
	if (cs)
		cs->InputMessage(event.toLocal8Bit());
}

void CsoundEngine::setSFDIR(QUrl dir)
{
	SFDIR = (dir.toString().startsWith("file:") ) ? dir.toLocalFile() : dir.path();
	qDebug()<<"Set SFDIR to: " << SFDIR;
}

void CsoundEngine::compileOrc(QString code)
{
	if (cs)
		cs->CompileOrc(code.toLocal8Bit());
}

void CsoundEngine::crash()
{
	QList <quint8> array;
	array[10] = 8; // index out of range crash
}

void CsoundEngine::handleChannelRequest(QString channel)
{
	qDebug() << Q_FUNC_INFO << "channel: " << channel;
	// TYPE??
	// test for controlChannel
	double value= getChannel(channel);
	qDebug() << "value: " << channel;
	emit newChannelValue(channel, value);

}



void CsoundEngine::timerSlot()
{
	if ( reptr) {
		emit newHeartBeat();
	}
}

