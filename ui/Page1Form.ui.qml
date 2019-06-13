import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as QC1

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

        QC1.TextArea {
            id: csdArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.6

            text: "Csd file"
        }

//        ScrollView {
//            id: messagesView
//            Layout.fillWidth: true
//            Layout.fillHeight: true
//            Layout.maximumHeight: parent.height * 0.4

//            clip: true
            QC1. TextArea {
                id: messageArea
                visible: true
                readOnly: true
                //ScrollBar.vertical.position: 1
                //anchors.fill: parent
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: parent.height * 0.4
                font.pointSize: 8
                font.family: "Courier"
                text: "Csound messages"
            }
//        }
    }
}
