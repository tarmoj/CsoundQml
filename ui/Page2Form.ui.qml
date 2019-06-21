import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    width: 600
    height: 400
    property alias harmonicsField: harmonicsField
    property alias getChannelButton: getChannelButton
    property alias slider: slider

    header: Label {
        text: qsTr("Widgets")
        font.pixelSize: Qt.application.font.pixelSize * 1.5
        padding: 10
    }

    Row {
        id: row
        y: 6
        spacing: 4
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 6

        Label {
            id: label
            text: qsTr("Freq:")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Slider {
            id: slider
            to: 1000
            from: 100
            value: 440
        }

        Label {
            id: label1
            text: qsTr("Harmonics:")
        }

        TextField {
            id: harmonicsField
            width: 40
            text: qsTr("?")
            horizontalAlignment: Text.AlignRight
        }

        Button {
            visible: false
            id: getChannelButton
            text: qsTr("Get")
        }
    }
}
