import "../components"
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutpage

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        contentHeight: content.height

        VerticalScrollDecorator {
        }

        Column {
            id: content

            width: parent.width

            PageHeader {
                title: qsTr("About Tarkka")
            }

            Column {
                width: parent.width
                spacing: Theme.paddingMedium

                Item {
                    height: appicon.height + Theme.paddingMedium
                    width: parent.width

                    Image {
                        id: appicon

                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../../images/appinfo.png" // FIX 2: Responsive image sizing so it never overflows the screen
                        width: Math.min(512, parent.width - (Theme.paddingLarge * 2))
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                    }

                }

                LabelSpacer {
                }

                LabelText {
                    text: qsTr("Tarkka is a digital magnifier designed specifically for Sailfish OS. It leverages native camera capabilities to help you observe details clearly.")
                }

                LabelSpacer {
                }

                LabelText {
                    text: qsTr("Released under the <a href='https://github.com/fravaccaro/harbour-tarkka/blob/main/LICENSE'>GNU GPLv3</a> license.")
                }

                LabelSpacer {
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Sources")
                    onClicked: Qt.openUrlExternally("https://github.com/fravaccaro/harbour-tarkka")
                }

                SectionHeader {
                    text: qsTr("Key features")
                }

                LabelText {
                    text: "<ul>" + "<li>" + qsTr("Smooth digital zoom up to 4x.") + "</li>" + "<li>" + qsTr("Specialized filters:") + " " + qsTr("Negative") + ", " + qsTr("Grayscale") + ", " + qsTr("Solarize") + ", " + qsTr("Whiteboard") + ", " + qsTr("Blackboard") + ", " + qsTr("Yellow on black") + ", " + qsTr("Black on yellow") + ", " + qsTr("Yellow on blue") + ", " + qsTr("Blue on yellow") + ", " + qsTr("White on blue") + ", " + qsTr("Blue on white") + ", " + qsTr("Red on black") + ", " + qsTr("Black on red") + ".</li>" + "<li>" + qsTr("Brightness adjustment.") + "</li>" + "<li>" + qsTr("Contrast adjustment.") + "</li>" + "<li>" + qsTr("Torch support for low-light environments.") + "</li>" + "<li>" + qsTr("Minimalist UI optimized for one-handed use.") + "</li>" + "</ul>"
                }

                SectionHeader {
                    text: qsTr("Feedback")
                }

                LabelText {
                    text: qsTr("If you want to provide feedback or report an issue, please use GitHub.")
                }

                LabelSpacer {
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Issues")
                    onClicked: Qt.openUrlExternally("https://github.com/fravaccaro/harbour-tarkka/issues")
                }

                SectionHeader {
                    text: qsTr("Support")
                }

                LabelText {
                    text: qsTr("If you like my work and want to buy me a beer, feel free to do it!")
                }

                LabelSpacer {
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Donate")
                    onClicked: Qt.openUrlExternally("https://www.paypal.me/fravaccaro")
                }

                LabelSpacer {
                }

                SectionHeader {
                    text: qsTr("Credits")
                }

                LabelText {
                    text: qsTr("Thanks to piggz and his amazing work on <a href='https://github.com/piggz/harbour-advanced-camera/tree/master'>Advancd Camera</a>, exposing the filter logic helped me immensely.")
                }

                SectionHeader {
                    text: qsTr("Translations")
                }

                DetailItem {
                    label: "Italiano"
                    value: "fravaccaro"
                }

                DetailItem {
                    label: "Norsk bokmål"
                    value: "frankps"
                }

                DetailItem {
                    label: "Svenska"
                    value: "Åke Engelbrektson"
                }

                LabelText {
                    text: qsTr("Request a new language or contribute to existing languages.")
                }

                LabelSpacer {
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Transifex")
                    onClicked: Qt.openUrlExternally("https://explore.transifex.com/fravaccaro/tarkka/")
                }

                LabelSpacer {
                }

            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

        }

    }

}