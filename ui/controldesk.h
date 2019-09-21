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
    void newCsdContent(QString csdText);
    void newQmlContent(QString qmlText);
    void newHtmlContent(QString htmlText);
    void loadHtmlFile(QUrl htmlFile);
    void errorMessage(QString message);

public Q_SLOTS:
	void startEngine();
	void stopEngine();
	void restartEngine();
	void checkEngine();
	void checkEngineProcess(QProcess::ProcessState newState);
	void compileCsd(QString csdText);
	//void compileCsd(QUrl csdFile);
    void loadCsd(QUrl fileUrl);
	QString getCsdTemplate();    
	void testSlot(QString channel);
	double getChannelValue(QString channel); // returns from channelValues hash


    // wrapper methods that can be called from qml/html object that send signal to engine

    void play(QString csdText) { emit compileCsdText(csdText); }
    void stop() { emit stopCsound(); }
    void setControlChannel(QString channel, double value) { emit  newControlChannelValue(channel, value); }
    void setStringChannel(QString channel, QString value) { emit  newStringChannelValue(channel, value); }
    void requestChannelValue(QString channel) { emit requestChannel(channel); } // TODO: consistent naming conventions
    // for testing only
    void crash() {  emit crashCsound(); }


private:
    int engineState;
	QTimer * checkEngineTimer;
	QProcess * engineProcess;
	QElapsedTimer heartBeatTime;
	QHash <QString, double> channelValues;
    QString  getFileContent(QString fileName);


};

#endif // CONTROLDESK_H
