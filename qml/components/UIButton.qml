import QtQuick 2.0
import Sailfish.Silica 1.0

IconButton {
    visible: !mainPage.isFrozen
    icon.width: Theme.iconSizeLarge
    icon.height: Theme.iconSizeLarge
    anchors.verticalCenter: parent.verticalCenter
    icon.color: pressed ? Theme.highlightColor : Theme.lightPrimaryColor
}
