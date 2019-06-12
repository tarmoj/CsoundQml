import QtQuick 2.9
import QtQuick.Controls 2.2

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Tabs")

    signal play(string csdText)
    signal stop()
    signal newControlChannelValue(string channel, double value)
    signal newStringChannelValue(string channel, string value)
    signal crash()

    Connections {
        target: controlDesk

        onNewEngineState: {
            console.log(state);
            engineStatusLabel.text = qsTr("Engine: ")+state
        }

        onNewCsoundMessage: {
            console.log(message);
            editorPage.messageArea.append(message);
        }
    }


    Component.onCompleted: editorPage.csdArea.text = controlDesk.getCsdTemplate()

    Item {


        anchors.fill: parent

        Row {
            id: menuRow
            spacing: 5
            Button {
                id: startButton
                text: "Play"
                onClicked: {
                    //controlDesk.setCsdText(editorPage.csdArea.text)
                    //controlDesk.start()
                    //controlDesk.compileCsd(editorPage.csdArea.text);
                    play(editorPage.csdArea.text)
                }

            }
            Button {
                id: stopButton
                text: "Stop"
                onClicked: stop() //controlDesk.stop_()
            }

            Button {
                id: engineButton
                text: qsTr("Restart engine")
                onClicked: controlDesk.restartEngine()

            }

            Button {
                id: crashButton
                text: qsTr("Crash engine")
                onClicked: crash()

            }

        }

        SwipeView {
            id: swipeView
            anchors.fill: parent
            anchors.topMargin: menuRow.height + 5
            currentIndex: tabBar.currentIndex

            Page1Form {
                id: editorPage

            }

            Page2Form {
                slider.onValueChanged: {
                    console.log("freq: ", slider.value)
                    newControlChannelValue("freq", slider.value)
}
            }
        }
    }

    footer:
        Row {
            id: footerRow
            width: parent.width

            Label {
                id: engineStatusLabel
                text: qsTr("Engine: ")
            }

        TabBar {
            id: tabBar
            currentIndex: swipeView.currentIndex

            TabButton {
                text: qsTr("Editor")
            }
            TabButton {
                text: qsTr("Widgets")
            }

        }
    }

}
