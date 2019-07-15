import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    anchors.fill: parent

    Row {
        id: row
        spacing: 4

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
    }

}
