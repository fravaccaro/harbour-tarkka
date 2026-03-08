import "../components"
import QtMultimedia 5.6
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: mainPage

    property int currentFilter: CameraImageProcessing.ColorFilterNone
    property bool isFrozen: false

    function syncCameraSettings() {
        camera.flash.mode = camera.isFlashOn ? Camera.FlashTorch : Camera.FlashOff;
        filterDelay.restart();
    }

    allowedOrientations: Orientation.Portrait

    Camera {
        id: camera

        property bool isFlashOn: false

        captureMode: Camera.CaptureVideo
        viewfinder.resolution: "1920x1080"
        onCameraStatusChanged: {
            if (cameraStatus === Camera.ActiveStatus)
                syncCameraSettings();

        }

        focus {
            focusMode: Camera.FocusContinuous
        }

    }

    Timer {
        id: filterDelay

        interval: 150
        repeat: false
        onTriggered: {
            camera.imageProcessing.colorFilter = CameraImageProcessing.ColorFilterNone;
            camera.imageProcessing.colorFilter = mainPage.currentFilter;
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height

        PushUpMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
            }

        }
        // Viewfinder and gestures

        Item {
            // PinchArea end

            anchors.fill: parent
            clip: true

            VideoOutput {
                id: viewfinder

                source: camera
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }

            Image {
                id: frozenView

                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                visible: mainPage.isFrozen

                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }

                }

            }

            // Pinch to zoom
            PinchArea {
                id: pinchArea

                property real initialZoom: 1
                property real initialScale: 1

                anchors.fill: parent
                // When fingers touch the screen
                onPinchStarted: {
                    if (mainPage.isFrozen)
                        initialScale = frozenView.scale;
                    else
                        initialZoom = zoomSlider.value;
                }
                // When fingers move
                onPinchUpdated: {
                    if (mainPage.isFrozen) {
                        // Zoom frozen image
                        var newScale = initialScale * pinch.scale;
                        frozenView.scale = Math.max(1, Math.min(newScale, 4));
                    } else {
                        // Update slider
                        var newZoom = initialZoom * pinch.scale;
                        zoomSlider.value = Math.max(zoomSlider.minimumValue, Math.min(newZoom, zoomSlider.maximumValue));
                    }
                }

                // When frozen view is disabled
                Connections {
                    target: mainPage
                    onIsFrozenChanged: {
                        if (!mainPage.isFrozen)
                            frozenView.scale = 1;

                    }
                }

                // Tap to focus
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!mainPage.isFrozen) {
                            var pointX = mouse.x / width;
                            var pointY = mouse.y / height;
                            camera.focus.focusMode = Camera.FocusMacro;
                            camera.focus.focusPointMode = Camera.FocusPointCustom;
                            camera.focus.customFocusPoint = Qt.point(pointX, pointY);
                            camera.searchAndLock();
                            focusIndicator.x = mouse.x - (focusIndicator.width / 2);
                            focusIndicator.y = mouse.y - (focusIndicator.height / 2);
                            focusIndicator.visible = true;
                            focusTimer.restart();
                        }
                    }
                }

            }

            Rectangle {
                id: focusIndicator

                width: Theme.itemSizeMedium
                height: Theme.itemSizeMedium
                color: "transparent"
                border.color: Theme.highlightColor
                border.width: 4
                radius: width / 2
                visible: false

                Timer {
                    id: focusTimer

                    interval: 1500
                    onTriggered: {
                        focusIndicator.visible = false;
                        // Back to continuous autofocus
                        camera.focus.focusMode = Camera.FocusContinuous;
                        camera.focus.focusPointMode = Camera.FocusPointAuto;
                        camera.unlock();
                    }
                }

            }

        }

        // --- Floating controls ---
        // Zoom, flash and buttons
        Column {
            id: floatingControls

            width: parent.width
            // Anchor on top of the overlay
            anchors.bottom: controlOverlay.top
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            // Slider Zoom and Flash row
            Item {
                width: parent.width
                height: flashButton.height
                visible: !mainPage.isFrozen

                Slider {
                    id: zoomSlider

                    anchors.left: parent.left
                    anchors.right: flashButton.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    label: "Zoom: " + value.toFixed(1) + "x"
                    minimumValue: 1
                    maximumValue: camera.maximumDigitalZoom > 1 ? camera.maximumDigitalZoom : 4
                    value: 1
                    onValueChanged: {
                        camera.digitalZoom = value;
                    }
                }

                IconButton {
                    id: flashButton

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    icon.source: camera.isFlashOn ? "image://theme/icon-camera-flash-on" : "image://theme/icon-camera-flash-off"
                    icon.color: pressed ? Theme.highlightColor : Theme.primaryColor
                    icon.width: Theme.iconSizeMedium
                    icon.height: Theme.iconSizeMedium
                    onClicked: {
                        camera.isFlashOn = !camera.isFlashOn;
                        syncCameraSettings();
                    }
                }

            }

            // Minus, freeze and plus row
            Row {
                id: controlsRow

                property real itemWidth: width / 3

                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                height: Theme.itemSizeLarge

                // Zoom - button
                Item {
                    width: controlsRow.itemWidth
                    height: parent.height

                    IconButton {
                        visible: !mainPage.isFrozen
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        icon.width: Theme.iconSizeLarge
                        icon.height: Theme.iconSizeLarge
                        icon.source: "image://theme/icon-m-remove"
                        icon.color: pressed ? Theme.highlightColor : Theme.primaryColor
                        onClicked: {
                            var step = (zoomSlider.maximumValue - zoomSlider.minimumValue) / 4;
                            zoomSlider.value = Math.max(zoomSlider.minimumValue, zoomSlider.value - step);
                        }
                    }

                }

                // Freeze Frame button
                Item {
                    width: controlsRow.itemWidth
                    height: parent.height

                    IconButton {
                        id: freezeButton

                        anchors.centerIn: parent
                        icon.source: mainPage.isFrozen ? "image://theme/icon-l-clear" : "image://theme/icon-camera-shutter"
                        icon.color: pressed ? Theme.highlightColor : Theme.primaryColor
                        icon.width: Theme.iconSizeLarge
                        icon.height: Theme.iconSizeLarge
                        onClicked: {
                            if (mainPage.isFrozen) {
                                // Go to live mode
                                mainPage.isFrozen = false;
                                frozenView.source = "";
                                camera.start();
                            } else {
                                // Freeze the image
                                viewfinder.grabToImage(function(result) {
                                    frozenView.source = result.url;
                                    mainPage.isFrozen = true;
                                    camera.isFlashOn = false;
                                    syncCameraSettings();
                                    camera.stop();
                                });
                            }
                        }
                    }

                }

                // Zoom + button
                Item {
                    width: controlsRow.itemWidth
                    height: parent.height

                    IconButton {
                        visible: !mainPage.isFrozen
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        icon.width: Theme.iconSizeLarge
                        icon.height: Theme.iconSizeLarge
                        icon.source: "image://theme/icon-m-add"
                        icon.color: pressed ? Theme.highlightColor : Theme.primaryColor
                        onClicked: {
                            var step = (zoomSlider.maximumValue - zoomSlider.minimumValue) / 4;
                            zoomSlider.value = Math.min(zoomSlider.maximumValue, zoomSlider.value + step);
                        }
                    }

                }

            }

        }

        // --- Overlay ---
        Rectangle {
            id: controlOverlay

            anchors.bottom: parent.bottom
            width: parent.width
            height: filterColumn.height + (Theme.paddingLarge * 2)
            color: Theme.rgba(Theme.overlayBackgroundColor, 0.6)
            // Opacity is used because visible would collapse the container
            opacity: mainPage.isFrozen ? 0 : 1
            enabled: !mainPage.isFrozen

            Column {
                id: filterColumn

                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                ComboBox {
                    width: parent.width
                    label: qsTr("Filter")
                    labelColor: Theme.primaryColor

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("None")
                            onClicked: {
                                currentFilter = CameraImageProcessing.ColorFilterNone;
                                syncCameraSettings();
                            }
                        }

                        MenuItem {
                            text: qsTr("Black and white")
                            onClicked: {
                                currentFilter = CameraImageProcessing.ColorFilterGrayscale;
                                syncCameraSettings();
                            }
                        }

                        MenuItem {
                            text: qsTr("Negative")
                            onClicked: {
                                currentFilter = CameraImageProcessing.ColorFilterNegative;
                                syncCameraSettings();
                            }
                        }

                        MenuItem {
                            text: qsTr("Solarize")
                            onClicked: {
                                currentFilter = CameraImageProcessing.ColorFilterSolarize;
                                syncCameraSettings();
                            }
                        }

                        MenuItem {
                            text: qsTr("Whiteboard")
                            onClicked: {
                                currentFilter = CameraImageProcessing.ColorFilterWhiteboard;
                                syncCameraSettings();
                            }
                        }

                        MenuItem {
                            text: qsTr("Blackboard")
                            onClicked: {
                                currentFilter = CameraImageProcessing.ColorFilterBlackboard;
                                syncCameraSettings();
                            }
                        }

                    }

                }

            }

            Behavior on opacity {
                FadeAnimation {
                }

            }

        }

        Connections {
            target: Qt.application
            onActiveChanged: {
                if (Qt.application.active) {
                    camera.start();
                } else {
                    camera.stop();
                    camera.isFlashOn = false;
                }
            }
        }

    }

}
