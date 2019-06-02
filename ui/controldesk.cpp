
#include "controldesk.h"

ControlDesk::ControlDesk(QObject *parent) : ControlDeskSimpleSource (parent),
	lastEngineTime(0), engineState(0),
	checkEngineTimer(new QTimer(this)), engineProcess(new QProcess(this))
{
	connect(checkEngineTimer, SIGNAL(timeout()), this, SLOT(checkEngine())  );
	//startEngine();
}

void ControlDesk::heartBeat(int time_) // NB! must be called by timer
{
	qDebug()<< "Hearbeat in source node: " << time_;
	lastEngineTime = time_;
	time.restart();

}

void ControlDesk::setEngineState(int state)
{
    qDebug()<< Q_FUNC_INFO << state;
	engineState = state;
}

void ControlDesk::handleCsoundMessage(QString message)
{
	//qDebug()<< Q_FUNC_INFO << message;
	emit newCsoundMessage(message);
}

void ControlDesk::start()
{
    qDebug()<< Q_FUNC_INFO;
	setUiCommand(PLAY);
}

void ControlDesk::stop()
{
    qDebug()<< Q_FUNC_INFO;
	setUiCommand(STOP);
}

void ControlDesk::startEngine()
{
	QString executable = "xterm  -e /home/tarmo/tarmo/programm/qt-projects/CsoundQml/build-csoundqml-Qt5_desktop-Debug/engine/engine"; // TODO: make universal
	//engineProcess->start(executable);
	engineProcess->execute(executable);
	lastEngineTime = 0;
	time.start();
	connect(engineProcess, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(checkEngineProcess(QProcess::ProcessState))  );
	checkEngineTimer->start(1000);
}

void ControlDesk::stopEngine()
{
	engineProcess->close();
	lastEngineTime = 0;
}

void ControlDesk::restartEngine()
{

}

void ControlDesk::checkEngine()
{

	qDebug()<< Q_FUNC_INFO << lastEngineTime  << " " << time.elapsed();
	//  this is stupid. should be handled vie QProcess:stateChanged
}

void ControlDesk::checkEngineProcess(QProcess::ProcessState newState)
{
	qDebug()<< Q_FUNC_INFO << newState;

}


