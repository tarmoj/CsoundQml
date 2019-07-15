import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

Page {
    width: 600
    height: 400
    property alias csdArea: csdArea
    property alias messageArea: messageArea

    header: Label {
        text: qsTr("Editor")
        font.pixelSize: Qt.application.font.pixelSize * 1.5
        padding: 10
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6
        anchors.margins: 10

        ScrollableTextArea {
            id: csdArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.6
        }

        ScrollableTextArea {
            id: messageArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.4
            textArea.readOnly: true
            textArea.height: parent.height // ? must be delvared for autoscroll?
            textArea.font.pointSize: 8
            textArea.font.family: "Courier"
            text: "Csound messages"
        }
    }
}
