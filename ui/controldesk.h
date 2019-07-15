#ifndef CONTROLDESK_H
#define CONTROLDESK_H

#include <QTimer>
#include <QProcess>
#include <QElapsedTimer>

#include "rep_controldesk_source.h"


class ControlDesk : public ControlDeskSimpleSource
{
    Q_OBJECT
public:
    explicit ControlDesk(QObject *parent = nullptr);
	~ControlDesk();

	virtual void heartBeat();
    virtual void setEngineState(int state);
	virtual void handleCsoundMessage(QString message);
	virtual void receiveChannelValue(QString channel, double value);

signals:
	void newCsoundMessage(QString message);
	void newEngineState(QString state);
	void channelValueReceived(QString channel, double value);

public Q_SLOTS:
	void startEngine();
	void stopEngine();
	void restartEngine();
	void checkEngine();
	void checkEngineProcess(QProcess::ProcessState newState);
	void compileCsd(QString csdText);
	//void compileCsd(QUrl csdFile);
	QString getCsdTemplate();
	void testSlot(QString channel);
	double getChannelValue(QString channel); // returns from channelValues hash

    void setControlChannel(QString channel, double value) { emit  newControlChannelValue(channel, value); }


private:
    int engineState;
	QTimer * checkEngineTimer;
	QProcess * engineProcess;
	QElapsedTimer heartBeatTime;
	QHash <QString, double> channelValues;

};

#endif // CONTROLDESK_H
