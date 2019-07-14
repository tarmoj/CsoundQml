import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

Page {
    width: 600
    height: 400
    property alias messagesView: messagesView
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

        ScrollView {
            id: csdView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.6

            background: Rectangle {
                color: "#323232" //Material.background //Qt.lighter(Material.background);
                border.color: "#404040"
                anchors.fill: parent
            }

            clip: true

            TextArea {
                id: csdArea
                text: "Csd file"
                selectByMouse: true
            }
        }

        ScrollView {
            id: messagesView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.4

            clip: true

            background: Rectangle {
                //color: Qt.lighter(Material.background)
                color: "#373737"
                border.color: "#404040"
                anchors.fill: parent
            }

            TextArea {
                id: messageArea
                visible: true
                readOnly: true
                height: parent.height
                selectByMouse: true
                //anchors.fill: parent
                font.pointSize: 8
                font.family: "Courier"
                text: "Csound messages"
            }
        }
    }
}
