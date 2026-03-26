import QtQuick 2.0
import Sailfish.Silica 1.0

Slider {
    id: root

    property string customLabelText: ""

    label: ""
    minimumValue: 1
    maximumValue: 4
    value: 1
    animateValue: false
    opacity: enabled ? (down ? 1 : 0.8) : 0.3

    Label {
        id: customLabel

        text: root.customLabelText
        color: root.down ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraSmall

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }

    }

    Rectangle {
        id: backgroundRect

        z: -1
        radius: height / 2
        color: Theme.rgba(Theme.overlayBackgroundColor, 0.7)
        opacity: root.down ? 0.8 : 0.7
        scale: root.down ? 1.05 : 1

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: customLabel.bottom
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
            topMargin: Theme.paddingMedium
            bottomMargin: -Theme.paddingMedium
        }

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

}
