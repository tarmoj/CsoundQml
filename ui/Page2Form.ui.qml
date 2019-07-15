import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    width: 600
    height: 400
    property alias widgetsArea: widgetsArea
    property alias widgetsText: widgetsText
    property alias refreshButton: refreshButton
    property alias harmonicsField: harmonicsField
    property alias slider: slider

    header: Label {
        text: qsTr("Widgets")
        font.pixelSize: Qt.application.font.pixelSize * 1.5
        padding: 10
    }

    Loader {
        id: widgetsArea
        y: 6
        height: parent.height * 0.4
        anchors {
            right: parent.right
            rightMargin: 6
            left: parent.left
            leftMargin: 6
        }
        source: "qrc:/demo.qml"
    }

    
    Column { // later get rid of it... keep it for testing's sake (similar to old)
        visible: false
        id: widgetsArea_old
        y: 6
        spacing: 6

        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 6


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

    
    ScrollView {
        id: scrollView
        x: 248
        y: 104
        width: widgetsArea.width
        height: 200
        anchors {
            horizontalCenter: parent.horizontalCenter

            top: widgetsArea.bottom
            topMargin: 6
            bottom: controlsRow.top
            bottomMargin: 6
        }
        clip: true

        TextArea {
            id: widgetsText
            anchors.fill: parent
            text: '
Slider {
id: volume
to: 1
from: 0
value: 0.8
}


'
        }
    }

    Row {
        id: controlsRow
        width: widgetsArea.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        spacing: 4
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: refreshButton
            text: qsTr("Refresh")
        }
    }
}
