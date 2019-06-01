#include "controldesk.h"

ControlDesk::ControlDesk(QObject *parent) : ControlDeskSimpleSource (parent),
    lastEngineTime(0), engineState(0)
{

}

void ControlDesk::heartBeat(int time) // NB! must be called by timer
{
    qDebug()<< "Hearbeat in source node: " << time;
	lastEngineTime = time;

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
