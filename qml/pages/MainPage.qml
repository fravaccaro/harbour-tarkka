import "../components"
import QtMultimedia 5.6
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: mainPage

    property int currentFilter: 0
    property bool isFrozen: false
    property int viewMode: 0
    property real brightnessValue: 1
    property real contrastValue: 1

    function syncCameraSettings() {
        camera.flash.mode = camera.isFlashOn ? Camera.FlashTorch : Camera.FlashOff;
    }

    allowedOrientations: Orientation.Portrait
    // What happens when the page is changed
    onStatusChanged: {
        if (status === PageStatus.Inactive || status === PageStatus.Deactivating) {
            camera.cameraState = Camera.UnloadedState;
            camera.flash.mode = Camera.FlashOff;
            camera.isFlashOn = false;
    }
        else if (status === PageStatus.Active && !mainPage.isFrozen)
            camera.cameraState = Camera.ActiveState;
    }

    Camera {
        id: camera

        property bool isFlashOn: false

        captureMode: Camera.CaptureVideo
        viewfinder.resolution: "1920x1080"

        focus {
            focusMode: Camera.FocusContinuous
        }

    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height
        interactive: !mainPage.isFrozen

        PushUpMenu {
            enabled: !mainPage.isFrozen

            MenuItem {
                text: qsTr("Filters")
                onClicked: viewMode = 0
                enabled: viewMode !== 0
            }

            MenuItem {
                text: qsTr("Brightness")
                onClicked: viewMode = 1
                enabled: viewMode !== 1
            }

            MenuItem {
                text: qsTr("Contrast")
                onClicked: viewMode = 2
                enabled: viewMode !== 2
            }

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

        }

        Item {
            anchors.fill: parent
            clip: true

            VideoOutput {
                id: viewfinder

                source: camera
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
                visible: false
            }

            ShaderEffect {
                id: shaderView

                property variant source
                property int filterType: mainPage.currentFilter
                property real brightness: mainPage.brightnessValue
                property real contrast: mainPage.contrastValue

                anchors.fill: parent
                visible: !mainPage.isFrozen
                fragmentShader: "
                    varying highp vec2 qt_TexCoord0;
                    uniform sampler2D source;
                    uniform lowp float qt_Opacity;
                    uniform int filterType;
                    uniform lowp float brightness;
                    uniform lowp float contrast;
                    void main() {
                        highp vec4 color = texture2D(source, qt_TexCoord0);
                        if (filterType == 1) { highp float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114)); color.rgb = vec3(gray); } // Grayscale
                        else if (filterType == 2) { color.rgb = 1.0 - color.rgb; } // Negative
                        else if (filterType == 3) { if (color.r > 0.5) color.r = 1.0 - color.r; if (color.g > 0.5) color.g = 1.0 - color.g; if (color.b > 0.5) color.b = 1.0 - color.b; } // Solarize
                        else if (filterType == 4) { highp float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114)); color.rgb = vec3(smoothstep(0.3, 0.6, gray)); } // Whiteboard
                        else if (filterType == 5) { highp float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114)); color.rgb = vec3(1.0 - smoothstep(0.3, 0.6, gray)); } // Blackboard
                        color.rgb *= brightness; // Brightness
                        color.rgb = (color.rgb - 0.5) * contrast + 0.5; // Contrast
                        gl_FragColor = color * qt_Opacity;
                    }
                "

                source: ShaderEffectSource {
                    sourceItem: viewfinder
                    hideSource: true
                }

            }

            Flickable {
                id: imageFlickable

                anchors.fill: parent
                visible: mainPage.isFrozen
                contentWidth: Math.max(width, frozenView.width * frozenView.scale)
                contentHeight: Math.max(height, frozenView.height * frozenView.scale)
                interactive: false
                boundsBehavior: Flickable.StopAtBounds

                Image {
                    id: frozenView

                    width: imageFlickable.width
                    height: imageFlickable.height
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    transformOrigin: Item.Center
                    scale: 1
                }

            }

            PinchArea {
                id: pinchArea

                property real initialScale: 1
                property real initialZoom: 1

                anchors.fill: parent
                onPinchStarted: {
                    if (mainPage.isFrozen)
                        initialScale = frozenView.scale;
                    else
                        initialZoom = zoomSlider.value;
                }
                onPinchUpdated: {
                    if (mainPage.isFrozen)
                        frozenView.scale = Math.max(1, Math.min(initialScale * pinch.scale, 4));
                    else
                        zoomSlider.value = Math.max(1, Math.min(initialZoom * pinch.scale, 4));
                }

                MouseArea {
                    id: interactionArea

                    property real lastX
                    property real lastY

                    anchors.fill: parent
                    onPressed: {
                        lastX = mouse.x;
                        lastY = mouse.y;
                        mouse.accepted = true;
                    }
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
                            console.log("Tap to focus sent to " + pointX + ", " + pointY);
                        }
                    }
                    onDoubleClicked: {
                        if (mainPage.isFrozen) {
                            frozenView.scale = 1;
                            imageFlickable.contentX = 0;
                            imageFlickable.contentY = 0;
                        }
                    }
                    onPositionChanged: {
                        if (mainPage.isFrozen && frozenView.scale > 1) {
                            var deltaX = lastX - mouse.x;
                            var deltaY = lastY - mouse.y;
                            imageFlickable.contentX = Math.max(0, Math.min(imageFlickable.contentX + deltaX, imageFlickable.contentWidth - imageFlickable.width));
                            imageFlickable.contentY = Math.max(0, Math.min(imageFlickable.contentY + deltaY, imageFlickable.contentHeight - imageFlickable.height));
                            lastX = mouse.x;
                            lastY = mouse.y;
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
                        camera.unlock();
                    }
                }

            }

        }

        Column {
            id: floatingControls

            width: parent.width
            anchors.bottom: controlOverlay.top
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            Item {
                width: parent.width
                height: Theme.itemSizeMedium
                visible: !mainPage.isFrozen

                UIButton {
                    id: switchCameraButton

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    icon.width: Theme.iconSizeMedium
                    icon.height: Theme.iconSizeMedium
                    icon.source: "image://theme/icon-m-sync"
                    onClicked: {
                        camera.flash.mode = Camera.FlashOff;
                        camera.isFlashOn = false;
                        zoomSlider.value = 1;
                        camera.position = (camera.position === Camera.BackFace) ? Camera.FrontFace : Camera.BackFace;
                    }
                }

                Slider {
                    id: zoomSlider

                    anchors.left: switchCameraButton.right
                    anchors.right: flashButton.left
                    opacity: pressed ? 1 : 0.8
                    label: "Zoom: " + value.toFixed(1) + "x"
                    minimumValue: 1
                    maximumValue: camera.maximumDigitalZoom > 1 ? camera.maximumDigitalZoom : 4
                    value: 1
                    onValueChanged: camera.digitalZoom = value
                }

                UIButton {
                    id: flashButton

                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    icon.width: Theme.iconSizeMedium
                    icon.height: Theme.iconSizeMedium
                    visible: camera.position === Camera.BackFace
                    icon.source: camera.isFlashOn ? "image://theme/icon-camera-flash-on" : "image://theme/icon-camera-flash-off"
                    onClicked: {
                        camera.isFlashOn = !camera.isFlashOn;
                        syncCameraSettings();
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
                        anchors.right: parent.right
                        icon.source: "image://theme/icon-m-remove"
                        onClicked: {
                            var step = (zoomSlider.maximumValue - zoomSlider.minimumValue) / 4;
                            zoomSlider.value = Math.max(zoomSlider.minimumValue, zoomSlider.value - step);
                        }
                    }

                }

                Item {
                    width: parent.width / 3
                    height: parent.height

                    UIButton {
                        id: freezeButton

                        visible: true
                        anchors.centerIn: parent
                        icon.source: mainPage.isFrozen ? "image://theme/icon-l-clear" : "image://theme/icon-camera-shutter"
                        onClicked: {
                            if (mainPage.isFrozen) {
                                mainPage.isFrozen = false;
                                camera.cameraState = Camera.ActiveState;
                            } else {
                                shaderView.grabToImage(function(result) {
                                    frozenView.source = result.url;
                                    mainPage.isFrozen = true;
                                    camera.cameraState = Camera.UnloadedState;
                                });
                            }
                        }
                    }

                }

                Item {
                    width: parent.width / 3
                    height: parent.height

                    UIButton {
                        anchors.left: parent.left
                        icon.source: "image://theme/icon-m-add"
                        onClicked: {
                            var step = (zoomSlider.maximumValue - zoomSlider.minimumValue) / 4;
                            zoomSlider.value = Math.min(zoomSlider.maximumValue, zoomSlider.value + step);
                        }
                    }

                }

            }

        }

        Rectangle {
            id: controlOverlay

            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.itemSizeLarge + (Theme.paddingMedium * 2)
            color: Theme.rgba(Theme.overlayBackgroundColor, 0.6)
            opacity: mainPage.isFrozen ? 0 : 1

            OverlayButton {
                id: filterIndicatorIcon

                icon.source: {
                    if (viewMode === 1)
                        return "image://theme/icon-m-day";

                    if (viewMode === 2)
                        return "image://theme/icon-m-light-contrast";

                    return "image://theme/icon-m-levels";
                }
            }

            SilicaListView {
                id: filterListView

                anchors.left: filterIndicatorIcon.right
                anchors.right: parent.right
                height: parent.height
                visible: viewMode === 0
                orientation: ListView.Horizontal
                spacing: Theme.paddingLarge
                clip: true

                model: ListModel {
                    ListElement {
                        name: qsTr("None")
                        filterType: 0
                    }

                    ListElement {
                        name: qsTr("Grayscale")
                        filterType: 1
                    }

                    ListElement {
                        name: qsTr("Negative")
                        filterType: 2
                    }

                    ListElement {
                        name: qsTr("Solarize")
                        filterType: 3
                    }

                    ListElement {
                        name: qsTr("Whiteboard")
                        filterType: 4
                    }

                    ListElement {
                        name: qsTr("Blackboard")
                        filterType: 5
                    }

                }

                delegate: BackgroundItem {
                    width: filterLabel.width + Theme.paddingLarge * 2
                    height: parent.height
                    onClicked: mainPage.currentFilter = filterType

                    Label {
                        id: filterLabel

                        anchors.centerIn: parent
                        text: name
                        color: mainPage.currentFilter === filterType ? Theme.highlightColor : Theme.primaryColor
                    }

                }

            }

            Item {
                anchors.left: filterIndicatorIcon.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: viewMode === 1

                Slider {
                    id: brightnessSlider

                    anchors.left: parent.left
                    anchors.right: resetBrightness.left
                    anchors.verticalCenter: parent.verticalCenter
                    valueText: value.toFixed(1)
                    minimumValue: 0.5
                    maximumValue: 2
                    value: brightnessValue
                    onValueChanged: brightnessValue = value
                }

                IconButton {
                    id: resetBrightness

                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-refresh"
                    onClicked: {
                        brightnessValue = 1;
                        brightnessSlider.value = brightnessValue;
                    }
                }

            }

            Item {
                anchors.left: filterIndicatorIcon.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: viewMode === 2

                Slider {
                    id: contrastSlider

                    anchors.left: parent.left
                    anchors.right: resetContrast.left
                    anchors.verticalCenter: parent.verticalCenter
                    valueText: value.toFixed(1)
                    minimumValue: 0.5
                    maximumValue: 2
                    value: contrastValue
                    onValueChanged: contrastValue = value
                }

                IconButton {
                    id: resetContrast

                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-refresh"
                    onClicked: {
                        contrastValue = 1;
                        contrastSlider.value = contrastValue;
                    }
                }

            }

        }

        // Unload camera hardware when not in use
        Connections {
            target: Qt.application
            onActiveChanged: {
                if (Qt.application.active) {
                    // Turn the camera on if on mainPage and NOT freeze view
                    if (mainPage.status === PageStatus.Active && !mainPage.isFrozen)
                        camera.cameraState = Camera.ActiveState;

                    mainPage.syncCameraSettings();
                } else {
                    // Turn everything off when the app is on the background
                    camera.cameraState = Camera.UnloadedState;
                    camera.flash.mode = Camera.FlashOff;
                    camera.isFlashOn = false;
                }
            }
        }

    }

}
