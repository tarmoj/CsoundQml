/*
	Copyright (C) 2016 Tarmo Johannes
	trmjhnns@gmail.com

	This file is part of vClick.

	vClick is free software; you can redistribute it and/or modify it under
	the terms of the GNU GENERAL PUBLIC LICENSE Version 3, published by
	Free Software Foundation, Inc. <http://fsf.org/>

	vClick is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with vClick; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/
#include "csoundengine.h"
#include <QDebug>
#include <QCoreApplication>
#include <QThread>
// remoteobject stuff:
#include <QSharedPointer>
#include <QRemoteObjectNode>
#include <qremoteobjectdynamicreplica.h>


CsoundEngine::CsoundEngine(QSharedPointer<ControlDeskReplica> ptr, QObject *parent) : QObject(parent),
    reptr(ptr)
{
	stopNow = false; // TODO: style -  initalize in class definition
	isRunning = false;
	cs = nullptr;
//	heartBeatTimer = new QTimer(this);
//	heartBeatTimer->start(1000);
//	connect(heartBeatTimer, SIGNAL(timeout()), this, SLOT(timerSlot())  );
//	time.start();
    initConnections();

}

CsoundEngine::~CsoundEngine()
{

}



void CsoundEngine::play(QString csd) {
#ifdef Q_OS_ANDROID
	cs = new AndroidCsound();
#else
	cs = new Csound();
#endif
    // set options
    QString csoundOptions= "-odac -d";

    foreach (QString option, csoundOptions.split(" ")) {
        qDebug()<<"Setting Csound option: " << option;
        cs->SetOption(option.toLocal8Bit().data());
    }

	// must check here, if it is already running. stop if is running. Tink, see CsoundQT and test....
	QString message;
    cs->CreateMessageBuffer(0); // also to stdout for debugging


    int result = cs->CompileCsd(csd.toLocal8Bit());

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

	} else {
        qDebug()<<"Could not compile and strart with file: " << csd;
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

void CsoundEngine::initConnections()
{
    connect(reptr.data() , SIGNAL(uiCommandChanged(int)), this, SLOT(handleUiCommand(int))  );
	connect(this, SIGNAL(newHeartBeat(int)), reptr.data(), SLOT(heartBeat(int))   );
	connect(this, SIGNAL(newCsoundMessage(QString)), reptr.data(), SLOT(handleCsoundMessage(QString))   );


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

void CsoundEngine::handleUiCommand(int command)
{
	qDebug()<< Q_FUNC_INFO << command;
	switch (command) {
        case 0: stop(); break;
        case 1: play("/home/tarmo/tarmo/csound/cs-lugu.csd");

	}
}

void CsoundEngine::timerSlot()
{
	if ( !reptr) {
		emit newHeartBeat(time.elapsed());
		//or maybe: reptr.data()->pushLastHeartBeat(now);

	}
	int now = time.elapsed();
	qDebug() << now;

}

