#ifndef CsoundEngine_H
#define CsoundEngine_H

#include <QObject>
#include <QUrl>
#include <QSharedPointer>
#include <QTime>

#ifdef Q_OS_ANDROID
	#include "AndroidCsound.hpp"
#else
	#include <csound.hpp>
#endif

#include "rep_controldesk_replica.h"

class CsoundEngine : public QObject
{
	Q_OBJECT
public:
    explicit CsoundEngine(QSharedPointer<ControlDeskReplica> ptr, QObject *parent = 0);
    ~CsoundEngine();

    double getChannel(QString channel);
    QString getStringChannel(QString channel);
    void initConnections();

Q_SIGNALS:
	void newCsoundMessage(QString message);
	void newHeartBeat();
	void newEngineState(int state);
	void newChannelValue(QString channel, double value); // QVariant?

public Q_SLOTS:
	void setChannel(QString channel, double value);
	void play(QString csdText);
	void stop();
    void pause();
    void readScore(QString event);
	void setSFDIR(QUrl dir);
	void compileOrc(QString code);
	void crash(); // for testing
	void handleChannelRequest(QString channel);

private Q_SLOTS:
	void timerSlot();

private:
#ifdef Q_OS_ANDROID
	AndroidCsound  *cs ;
#else
	Csound  *cs;
#endif
	bool stopNow, isRunning;
    QString SFDIR;
    QSharedPointer<ControlDeskReplica> reptr;// holds reference to replica
	QTimer *heartBeatTimer;
	QTime time;
};

#endif // CsoundEngine_H
