import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    anchors.fill: parent

    Connections {
        target: csound

        onChannelValueReceived: {
            if (channel == "test") {
                harmonicsField.text = value
            }
        }

    }

    Row {
        id: row
        spacing: 8

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
            onValueChanged: csound.setControlChannel("freq", value)

        }

        Label {
            id: label1
            text: qsTr("Harmonics:")
        }

        TextField {
            id: harmonicsField
            width: 40
            text: "?"
            horizontalAlignment: Text.AlignRight
        }

    }

}
