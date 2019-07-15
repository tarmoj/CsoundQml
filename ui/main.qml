import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("CsoundQml -  test")

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

    Settings {
        property alias lastCsdFile: openFileDialog.file
        property alias lastOpenFolder: openFileDialog.folder
        property alias lastSaveFolder: saveFileDialog.folder
    }

    function openFile(fileUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        return request.responseText;
    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }

    function getBasename(url) {
        var basename = url.toString()
        basename = basename.slice(0, basename.lastIndexOf("/")+1)
        return basename
    }

    FileDialog {
        id: openFileDialog
        nameFilters: ["Csd files (*.csd)", "All files (*)"]
        //folder: lastFolder
        onAccepted: {
            folder = getBasename(file)
            saveFileDialog.currentFile = file // does not work
            editorPage.csdArea.text = openFile(openFileDialog.file)
        }
    }

    FileDialog {
        id: saveFileDialog
        //currentFile:  "autotune.csd"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Csd files (*.csd)", "All files (*)"]
        onAccepted: {
            folder = getBasename(file)
            saveFile(saveFileDialog.file, editorPage.csdArea.text)
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
                id: openButton
                text: "Open"
                onClicked: openFileDialog.open()
            }

            Button {
                id: saveButton
                text: "Save"
                onClicked: saveFileDialog.open()
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

                slider.onValueChanged: {
                    console.log("freq: ", slider.value)
                    newControlChannelValue("freq", slider.value)
                }

                refreshButton.onClicked:  {
                    console.log("refresh Widget view")
                    var newObject = Qt.createComponent()( "import QtQuick 2.9;
import QtQuick.Controls 2.2; import QtQuick.Layouts 1.3; " + widgetsText.text, widgetsArea, "Page2Form" );
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
