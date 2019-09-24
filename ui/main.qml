import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0
import QtWebKit 3.0 // later versions: QtWebView

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("CsoundQml -  test")


    Connections {
        target: csound

        onNewEngineState: {
            //console.log(state);
            engineStatusLabel.text = qsTr("Engine: ")+state
        }

        onNewCsoundMessage: {
            //console.log(message);
            editorPage.messageArea.textArea.append(message) // this works! no workaround any more!
        }

        onNewCsdContent: {
            editorPage.csdArea.text = csdText;

        }

        onNewQmlContent: {
           widgetsPage.widgetsText.text = qmlText;
           widgetsPage.refreshButton.clicked();
           widgetsPage.qmlFile =  editorPage.csdFile.toString().replace(".csd", ".qml")
        }

//        onNewHtmlContent: {
//            console.log(htmlText);
//        }
        onLoadHtmlFile: {
            console.log("Load html: ", htmlFile)
            htmlPage.url = htmlFile;
        }

    }

    Settings {
        id: settings
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

    function saveFile(fileUrl, text) { // later maybe get rid of it and handle via C++ class
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        request.onload = function () { console.log ("LOADED!"); }
        request.onreadystatechange = function () {
            console.log(request.readyState, request.status, request.statusText)
            if (request.readyState === 200 ) {
                console.log("Done")
            }
        }

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
            //editorPage.csdArea.text = openFile(openFileDialog.file)
            csound.loadCsd(openFileDialog.file) // loads csd, qml and html from the same fodler if they are with the same name
            editorPage.csdFile = file
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
            if ( widgetsPage.qmlFile !== "" ) {
                console.log ("Should save qml file, too.")
                //saveFile(widgetsPage.qmlFile , widgetsPage.widgetsText.text)
            }
        }
    }



    Component.onCompleted: csound.loadCsd(settings.lastCsdFile)

    Item {


        anchors.fill: parent

        Column {
            id: menuColumn
            spacing: 5
            x: 5; y:5

            Row {
                id: menuRow
                spacing: 5


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
                    onClicked: csound.restartEngine()

                }

                Button {
                    id: crashButton
                    text: qsTr("Crash engine")
                    onClicked: csound.crash()

                }

            }
            Row {
                id: menuRow2
                spacing: 5
                Button {
                    id: startButton
                    text: "Play"
                    onClicked: {
                        editorPage.messageArea.text = "" ; //clear
                        csound.play(editorPage.csdArea.text)
                    }

                }
                Button {
                    id: stopButton
                    text: "Stop"
                    onClicked: csound.stop()
                }

                Button {
                    id: evaluateButton
                    text: "Eval. selection"
                    onClicked: {
                        var selectedText = editorPage.csdArea.textArea.selectedText
                        console.log("selected: ", selectedText)
                        if (selectedText.length > 0) {
                            console.log("Compile: ", selectedText)
                            csound.compileOrc(selectedText);
                        }
                        editorPage.csdArea.textArea.deselect()
                    }
                }


            }
        }

        SwipeView {
            id: swipeView
            anchors.fill: parent
            anchors.topMargin: menuColumn.height + 5
            currentIndex: tabBar.currentIndex

            Page1Form {
                id: editorPage
                property url csdFile: ""

                //csdArea.textArea.onSelectedTextChanged: console.log("SelText: ", csdArea.textArea.selectedText )

            }

            Page2Form {
                id: widgetsPage
                property url qmlFile: ""
                property url tempQmlFile: StandardPaths.writableLocation(StandardPaths.TempLocation) + "/tmp.qml"

                Component.onCompleted: if (qmlFile==="") widgetsText.text = openFile("qrc:/demo.qml")


                Timer { // necessary to set the source  a bit later. Bad code. Use some signal/event on save XML request
                    id: setWidgetsTimer
                    running: false
                    repeat: false
                    interval: 100

                    onTriggered: widgetsPage.widgetsArea.source = widgetsPage.tempQmlFile  + "?t=" + Date.now() // force to update
                }

                refreshButton.onClicked:  {
                    console.log("refresh Widget view")
                    saveFile(widgetsPage.tempQmlFile, widgetsText.text)
                    // TODO: catch some kind of signal when save is fihished. For now:
                    setWidgetsTimer.start() // give some time for save to finish
                }
            }

            Page {
                id: htmlPage // NB! websockets to csound not implemented yet!
                property alias url: webview.url
                width: 800
                height: 600

                Label {text: "Only Webview now. No connection to Csound."}

                ScrollView {
                    anchors.fill: parent
                    anchors.topMargin: 50
                    WebView {
                        id: webview
                        url: ""
                        anchors.fill: parent
//                        onNavigationRequested: {
//                            // detect URL scheme prefix, most likely an external link
//                            var schemaRE = /^\w+:/;
//                            if (schemaRE.test(request.url)) {
//                                request.action = WebView.AcceptRequest;
//                            } else {
//                                request.action = WebView.IgnoreRequest;
//                                // delegate request.url here
//                            }
//                        }
                    }
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

            TabButton {
                text: qsTr("HTML")
            }

        }
    }

}
