import CameraGallery 1.0
import QtMultimedia 5.6
import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: root

    property bool isFrozen: false
    property var cameraObj
    property alias activeZoom: zoomSlider.value
    property alias frozenZoom: frozenZoomSlider.value
    property alias isSaving: saveButton.isSaving
    property alias isSharing: shareButton.isSharing

    signal flashClicked()
    signal saveClicked()
    signal shareClicked()
    signal freezeClicked()
    signal unfreezeClicked()

    width: parent.width
    spacing: Theme.paddingLarge

    Item {
        width: parent.width
        height: Theme.itemSizeMedium

        UIButton {
            id: switchCameraButton

            visible: !root.isFrozen
            enabled: visible
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            icon.width: Theme.iconSizeMedium
            icon.height: Theme.iconSizeMedium
            icon.source: "image://theme/icon-camera-switch"
            onClicked: {
                root.cameraObj.flash.mode = Camera.FlashOff;
                root.cameraObj.isFlashOn = false;
                zoomSlider.value = 1;
                root.cameraObj.position = (root.cameraObj.position === Camera.BackFace) ? Camera.FrontFace : Camera.BackFace;
            }
        }

        UIButton {
            id: shareButton

            property bool isSharing: false

            visible: root.isFrozen
            enabled: visible
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            icon.width: Theme.iconSizeMedium
            icon.height: Theme.iconSizeMedium
            icon.source: "image://theme/icon-m-share"
            icon.opacity: isSharing ? 0 : 1
            onClicked: {
                if (!isSharing)
                    root.shareClicked();

            }

            BusyIndicator {
                anchors.centerIn: parent
                size: BusyIndicatorSize.Medium
                running: shareButton.isSharing
                visible: running
            }

        }

        ZoomSlider {
            id: zoomSlider

            visible: !root.isFrozen
            anchors.left: switchCameraButton.right
            anchors.right: flashButton.left
            enabled: root.cameraObj && root.cameraObj.cameraState === Camera.ActiveState
            stepSize: 1
            maximumValue: root.cameraObj && root.cameraObj.maximumDigitalZoom > 1 ? root.cameraObj.maximumDigitalZoom : 4
            customLabelText: "Zoom: " + Math.round(value) + "x"
            onValueChanged: {
                if (root.cameraObj && root.cameraObj.cameraState === Camera.ActiveState) {
                    var absoluteMax = maximumValue - 0.01; // The max zoom would not work without this
                    var safeZoom = Math.max(minimumValue, Math.min(absoluteMax, value));
                    console.log("Slider clicked/dragged! Safe zoom is now:", safeZoom);
                    console.log("Slider value:", zoomSlider.value);
                    root.cameraObj.digitalZoom = safeZoom;
                }
            }
        }

        ZoomSlider {
            id: frozenZoomSlider

            visible: root.isFrozen
            anchors.left: switchCameraButton.right
            anchors.right: flashButton.left
            stepSize: 0.1
            maximumValue: 4
            customLabelText: "Zoom: " + Math.round(value * 10) / 10 + "x"
        }

        UIButton {
            id: flashButton

            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            icon.width: Theme.iconSizeMedium
            icon.height: Theme.iconSizeMedium
            enabled: root.cameraObj && root.cameraObj.cameraState === Camera.ActiveState && !root.isFrozen
            visible: CameraConfigs.supportedFlashModes.length > 0 && !root.isFrozen
            icon.source: root.cameraObj && root.cameraObj.isFlashOn ? "image://theme/icon-camera-flash-on" : "image://theme/icon-camera-flash-off"
            onClicked: {
                root.flashClicked();
            }
        }

        UIButton {
            id: saveButton

            property bool isSaving: false

            visible: root.isFrozen
            enabled: visible
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            icon.width: Theme.iconSizeMedium
            icon.height: Theme.iconSizeMedium
            icon.source: "image://theme/icon-m-downloads"
            icon.opacity: isSaving ? 0 : 1
            onClicked: {
                if (!isSaving)
                    root.saveClicked();

            }

            BusyIndicator {
                anchors.centerIn: parent
                size: BusyIndicatorSize.Medium
                running: saveButton.isSaving
                visible: running
            }

        }

    }

    Row {
        id: controlsRow

        width: parent.width
        height: Theme.itemSizeLarge

        Item {
            width: parent.width / 3
            height: parent.height

            UIButton {
                visible: !root.isFrozen
                anchors.right: parent.right
                enabled: root.cameraObj && root.cameraObj.cameraState === Camera.ActiveState && !root.isFrozen
                icon.source: "image://theme/icon-m-remove"
                backgroundSize: Theme.iconSizeLarge - Theme.paddingMedium
                onClicked: {
                    var step = (zoomSlider.maximumValue - zoomSlider.minimumValue) / 4;
                    zoomSlider.value = Math.max(zoomSlider.minimumValue, zoomSlider.value - step);
                }
            }

            UIButton {
                visible: root.isFrozen
                enabled: visible
                anchors.right: parent.right
                icon.source: "image://theme/icon-m-remove"
                backgroundSize: Theme.iconSizeLarge - Theme.paddingMedium
                onClicked: {
                    var step = (frozenZoomSlider.maximumValue - frozenZoomSlider.minimumValue) / 4;
                    frozenZoomSlider.value = Math.max(frozenZoomSlider.minimumValue, frozenZoomSlider.value - step);
                }
            }

        }

        Item {
            width: parent.width / 3
            height: parent.height

            UIButton {
                id: freezeButton

                visible: !root.isFrozen
                enabled: visible
                anchors.centerIn: parent
                icon.source: "image://theme/icon-camera-shutter-release"
                onClicked: root.freezeClicked()
            }

            UIButton {
                id: unfreezeButton

                visible: root.isFrozen
                enabled: visible
                anchors.centerIn: parent
                icon.source: "image://theme/icon-l-clear"
                backgroundSize: Theme.iconSizeLarge
                onClicked: {
                    frozenZoomSlider.value = 1;
                    root.unfreezeClicked();
                }
            }

        }

        Item {
            width: parent.width / 3
            height: parent.height

            UIButton {
                visible: !root.isFrozen
                anchors.left: parent.left
                enabled: root.cameraObj && root.cameraObj.cameraState === Camera.ActiveState && !root.isFrozen
                icon.source: "image://theme/icon-m-add"
                backgroundSize: Theme.iconSizeLarge - Theme.paddingMedium
                onClicked: {
                    var step = (zoomSlider.maximumValue - zoomSlider.minimumValue) / 4;
                    zoomSlider.value = Math.min(zoomSlider.maximumValue, zoomSlider.value + step);
                }
            }

            UIButton {
                visible: root.isFrozen
                enabled: visible
                anchors.left: parent.left
                icon.source: "image://theme/icon-m-add"
                backgroundSize: Theme.iconSizeLarge - Theme.paddingMedium
                circleBorderWidth: 2
                onClicked: {
                    var step = (frozenZoomSlider.maximumValue - frozenZoomSlider.minimumValue) / 4;
                    frozenZoomSlider.value = Math.min(frozenZoomSlider.maximumValue, frozenZoomSlider.value + step);
                }
            }

        }

    }

}
