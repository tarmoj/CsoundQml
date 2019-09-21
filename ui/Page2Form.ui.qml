import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    width: 600
    height: 400
    property alias widgetsArea: widgetsArea
    property alias widgetsText: widgetsText
    property alias refreshButton: refreshButton

    header: Label {
        text: qsTr("Widgets")
        font.pixelSize: Qt.application.font.pixelSize * 1.5
        padding: 10
    }

    Loader {
        id: widgetsArea
        y: 6
        height: parent.height * 0.5
        anchors {
            right: parent.right
            rightMargin: 6
            left: parent.left
            leftMargin: 6
        }
        source: "qrc:/demo.qml"
    }

    ScrollableTextArea {
        id: widgetsText
        width: widgetsArea.width
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: widgetsArea.bottom
            topMargin: 6
            bottom: controlsRow.top
            bottomMargin: 6
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
