import Opal.About 1.0 as A
import QtQuick 2.0
import Sailfish.Silica 1.0

A.AboutPageBase {
    appName: "Tarkka"
    appIcon: Qt.resolvedUrl("../../images/appinfo.png")
    appVersion: "0.6.0"
    description: qsTr("Tarkka is a digital magnifier designed specifically for Sailfish OS. It leverages native camera capabilities to help you observe details clearly.")
    authors: ["fravaccaro"]
    homepageUrl: "https://github.com/fravaccaro/harbour-tarkka"
    sourcesUrl: "https://github.com/fravaccaro/harbour-tarkka"
    translationsUrl: "https://explore.transifex.com/fravaccaro/tarkka/"
    licenses: A.License {
        spdxId: "GPL-3.0-or-later"
    }

    donations.text: qsTr("If you like my work and want to buy me a beer, feel free to do it!")
    donations.services: [
        A.DonationService {
            name: "Liberapay"
            url: "https://liberapay.com/fravaccaro"
        }
    ]

    contributionSections: [
        A.ContributionSection {
            title: qsTr("Translations")
            groups: [
                A.ContributionGroup {
                    title: "Italiano"
                    entries: ["fravaccaro"]
                },
                A.ContributionGroup {
                    title: "Norsk bokmål"
                    entries: ["frankps"]
                },
                A.ContributionGroup {
                    title: "Svenska"
                    entries: ["Åke Engelbrektson"]
                }
            ]
        }
    ]

    extraSections: [
        A.InfoSection {
            title: qsTr("Key features")
            text: qsTr("Smooth digital zoom up to 4x, specialized camera filters, brightness and contrast adjustment, torch support, and a minimalist UI optimized for one-handed use.")
        },
        A.InfoSection {
            title: qsTr("Feedback")
            text: qsTr("If you want to provide feedback or report an issue, please use GitHub.")
            buttons: [
                A.InfoButton {
                    text: qsTr("Issues")
                    onClicked: openOrCopyUrl("https://github.com/fravaccaro/harbour-tarkka/issues", text)
                }
            ]
        },
        A.InfoSection {
            title: qsTr("Credits")
            text: qsTr("Thanks to piggz and his amazing work on Advanced Camera, exposing the filter logic helped me immensely.")
        }
    ]
}
