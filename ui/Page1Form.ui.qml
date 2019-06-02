import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    width: 600
    height: 400
    property alias engineButton: engineButton
    property alias stopButton: stopButton
    property alias startButton: startButton

    header: Label {
        text: qsTr("Page 1")
        font.pixelSize: Qt.application.font.pixelSize * 2
        padding: 10
    }

    Row {
        spacing: 5
        Button {
            id: startButton
            text: "Start"
        }
        Button {
            id: stopButton
            text: "Stop"
        }

        Button {
            id: engineButton
            text: qsTr("Engine")
            checkable: true
        }
    }
}
