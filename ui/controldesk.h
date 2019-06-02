#ifndef CONTROLDESK_H
#define CONTROLDESK_H

#include <QTimer>
#include <QProcess>

#include "rep_controldesk_source.h"

#define STOP 0
#define PLAY 1
// etc

class ControlDesk : public ControlDeskSimpleSource
{
    Q_OBJECT
public:
    explicit ControlDesk(QObject *parent = nullptr);

    virtual void heartBeat(int time);
    virtual void setEngineState(int state);
	virtual void handleCsoundMessage(QString message);

signals:
	void newCsoundMessage(QString message);

public Q_SLOTS:
    void start();
    void stop();
	void startEngine();
	void stopEngine();
	void restartEngine();
	void checkEngine();
	void checkEngineProcess(QProcess::ProcessState newState);

private:
    int lastEngineTime;
    int engineState;
	QTimer * checkEngineTimer;
	QProcess * engineProcess;
	QTime time;

};

#endif // CONTROLDESK_H
