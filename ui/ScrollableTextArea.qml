import QtQuick 2.0
import QtQuick.Controls 2.2

ScrollView {
    //anchors.fill: parent
    width: 400; height: 200
    property alias textArea: textArea
    property alias text: textArea.text
    clip: true

    background: Rectangle {
        color: "#323232" //Material.background //Qt.lighter(Material.background);
        border.color: "#404040"
        anchors.fill: parent
    }


    TextArea {
        id: textArea
        selectByMouse: true
    }
}
