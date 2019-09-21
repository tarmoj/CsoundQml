#include <QCoreApplication>
#include "controldesk.h"
#include <QFileDialog>

ControlDesk::ControlDesk(QObject *parent) : ControlDeskSimpleSource (parent),
	engineState(LOST),
	checkEngineTimer(new QTimer(this)), engineProcess(new QProcess(this))
{
	startEngine();

}

ControlDesk::~ControlDesk()
{
	stopEngine();
}

void ControlDesk::heartBeat() // NB! must be called by timer
{
	heartBeatTime.restart();
}

void ControlDesk::setEngineState(int state)
{
    qDebug()<< Q_FUNC_INFO << state;
	engineState = state;
	switch (state) {
		case PLAYING: emit newEngineState(tr("playing")); break;
		case STOPPED: emit newEngineState(tr("stopped")); break;
		case PAUSED: emit newEngineState(tr("paused")); break;
		case RENDERING: emit newEngineState(tr("rendering")); break;
		case RECORDING: emit newEngineState(tr("recording")); break;
		case RUNNING: emit newEngineState(tr("connected")); break;
		case LOST: emit newEngineState(tr("disconnected")); break;

	}
}

void ControlDesk::handleCsoundMessage(QString message)
{
	//qDebug()<< Q_FUNC_INFO << message;
	emit newCsoundMessage(message);
}

void ControlDesk::receiveChannelValue(QString channel, double value) // QVariant
{
	qDebug()<< Q_FUNC_INFO << channel << " " << value;
	// put into hash and emit signal receivedChannelValue
	channelValues.insert(channel, value);
	emit channelValueReceived(channel, value);
}


void ControlDesk::startEngine()
{
	QString path =  QCoreApplication::applicationDirPath();
	QString executable = path + "/engine"; // NB! use make install to put them into same directory!  //  "/../engine/engine"; //
	qDebug() << executable;
	//QString executable = "xterm -e /home/tarmo/tarmo/programm/qt-projects/CsoundQml/build-csoundqml-Qt5_desktop-Debug/engine/engine &"; // TODO: make universal
	engineProcess->start(executable);
    //QObject::connect(engineProcess, SIGNAL(readyRead()) )
	heartBeatTime.start();
	connect(engineProcess, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(checkEngineProcess(QProcess::ProcessState))  );
	checkEngineTimer->start(1000);
}

void ControlDesk::stopEngine()
{
	engineProcess->close();
}

void ControlDesk::restartEngine()
{
	stopEngine();
	QThread::sleep(1);
	startEngine();
}

void ControlDesk::checkEngine()
{
	qint64 elapsed = heartBeatTime.elapsed();
	//qDebug()<< Q_FUNC_INFO << elapsed;
	if (elapsed > 2000) {
		qDebug() << "Engine seems not to be running ";
	}
	//  this is kind of stupid. should be handled via QProcess:stateChanged. But for any case...
}

void ControlDesk::checkEngineProcess(QProcess::ProcessState newState)
{
	qDebug()<< Q_FUNC_INFO << newState;
	switch (newState) {
		case QProcess::Starting: emit newEngineState(tr("starting")); break;
	case QProcess::Running:  setEngineState(RUNNING); break;
		case QProcess::NotRunning:  setEngineState(LOST); break;

	}


}

void ControlDesk::compileCsd(QString csdText)
{
	// for now:
	if (csdText.isEmpty()) {
		csdText = getCsdTemplate();
	}

	emit compileCsdText(csdText);

}

void ControlDesk::loadCsd(QUrl fileUrl)
{
    QString fileName = fileUrl.toLocalFile();
    if (!QFile::exists(fileName)) {
        qDebug() << fileName << " does not exist.";
        emit errorMessage(fileName + " does not exist.");
        return;
    }   else {
        emit newCsdContent(getFileContent(fileName) );
    }

    QString qmlName = fileName;
    qmlName.replace(".csd", ".qml"); // TODO: uppercase
    if (QFile::exists(qmlName)) {
        emit newQmlContent(getFileContent(qmlName) );
    }

    QString htmlName = fileName;
    htmlName.replace(".csd", ".html"); // TODO: uppercase
    if (QFile::exists(htmlName)) {
        //emit newQmlContent(getFileContent(htmlName) );
        emit loadHtmlFile(QUrl::fromLocalFile(htmlName));
    }
}


QString ControlDesk::getCsdTemplate()
{
	QString csdTemplate =
R"(
<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

print 10/3

;; channels must be declared with chn_k
chn_k "test",3
chn_k "freq", 3

//chnset 12, "test"
chnset 440, "freq"


alwayson "controller"
instr controller
    ktrig metro 0.5 // NB! 1/2 returns 0 on first run!!!
    schedkwhen ktrig, 0, 0, "sound", 0, 0.5
endin

instr sound
	ifreq chnget "freq"
	iharm = int(random:i( 1, 15) )
	chnset iharm, "test"
    asig buzz 0.2*adsr:a(0.1,0.1, 0.5, p3/2), ifreq, iharm, -1
    outs asig, asig
endin

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>
)";
    return csdTemplate;
}

QString ControlDesk::getFileContent(QString fileName)
{

    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return "Error opening file " + fileName;
    }
    QString csdText = QString(file.readAll());
    return csdText;

}

void ControlDesk::testSlot(QString channel)
{
	qDebug() << Q_FUNC_INFO << channel;
	emit requestChannelValue(channel);
}

double ControlDesk::getChannelValue(QString channel)
{
	double value = -1;
	if ( channelValues.contains(channel) ) {
		value = channelValues[channel];
	} else {
		qDebug() << "Channel " << channel << " is unknown. Have you requested it?";
	}
	return  value;
}


