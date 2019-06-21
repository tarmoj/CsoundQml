import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

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
    signal requestChannelValue(string channel)

    Connections {
        target: controlDesk

        onNewEngineState: {
            //console.log(state);
            engineStatusLabel.text = qsTr("Engine: ")+state
        }

        onNewCsoundMessage: {
            //console.log(message);
            editorPage.messageArea.append(message);
            // workaround for autoscrioll:
            if (editorPage.messageArea.height>editorPage.messagesView.contentItem.height)  {
                editorPage.messagesView.contentItem.contentY =   editorPage.messageArea.height - editorPage.messagesView.contentItem.height
            }
        }

        onChannelValueReceived: {
            console.log(channel, value)
            if (channel == "test") {
                widgetsPage.harmonicsField.text = value
            }
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
                    editorPage.messageArea.text = "" ; //clear
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
                id: widgetsPage
                getChannelButton.onClicked: {
                    requestChannelValue("test")
                    //controlDesk.testSlot("test")
                }
                slider.onValueChanged: {
                    console.log("freq: ", slider.value)
                    newControlChannelValue("freq", slider.value)
                }

            }
        }
    }

    footer:
        RowLayout {
            id: footerRow
            width: parent.width

            Label {
                id: engineStatusLabel
                text: qsTr("Engine: ")
            }

        TabBar {
            id: tabBar
            currentIndex: swipeView.currentIndex
            Layout.fillWidth:  true

            TabButton {
                text: qsTr("Editor")
            }
            TabButton {
                text: qsTr("Widgets")
            }

        }
    }

}
