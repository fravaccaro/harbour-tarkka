import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.SupportMe 1.0
import "pages"
import "components"

ApplicationWindow {
    id: app

    property bool isLightTheme: (Theme.colorScheme === Theme.LightOnDark) ? false : true

    function showSupportDialog() {
        askForSupport.show()
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    initialPage: Component {
        MainPage {
        }

    }

    AskForSupport {
        id: askForSupport

        contents: Component {
            TarkkaSupportDialog {
            }
        }
    }

}
