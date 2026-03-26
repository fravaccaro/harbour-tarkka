import QtQuick 2.0
import Sailfish.Silica 1.0

IconButton {
    id: root

    property real circleBorderWidth: 0
    property color circleBorderColor: "transparent"
    property real backgroundSize: icon.width + Theme.paddingMedium

    visible: !mainPage.isFrozen
    icon.width: Theme.iconSizeLarge
    icon.height: Theme.iconSizeLarge
    anchors.verticalCenter: parent.verticalCenter
    icon.color: pressed ? Theme.secondaryColor : Theme.primaryColor
    icon.scale: pressed ? 0.9 : 1
    opacity: enabled ? 1 : 0.3

    Rectangle {
        anchors.centerIn: parent
        width: root.backgroundSize
        height: width
        radius: width / 2
        color: Theme.rgba(Theme.overlayBackgroundColor, 0.7)
        opacity: root.down ? 0.8 : 0.7
        border.width: root.circleBorderWidth
        border.color: root.circleBorderColor
        z: -1
        scale: root.pressed ? 1.05 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }

        }

    }

    Behavior on icon.scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }

    }

}
