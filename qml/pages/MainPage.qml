import "../components"
import Nemo.Notifications 1.0
import QtMultimedia 5.6
import QtQuick 2.0
import Sailfish.Share 1.0
import Sailfish.Silica 1.0

Page {
    id: mainPage

    property int currentFilter: 0
    property bool isFrozen: false
    property int viewMode: 0
    property real brightnessValue: 1
    property real contrastValue: 1
    property alias cameraObj: camera
    property var lastFreezeFrame
    property string savedImagePath
    property var resolutionCache: ({})

    function funcCameraOff() {
        console.log("Camera off");
        camera.stop();
        camera.cameraState = Camera.UnloadedState;
    }

    function funcCameraOn() {
        console.log("Camera on");
        camera.cameraState = Camera.ActiveState;
    }

    function funcFlashOff() {
        console.log("Flash off");
        camera.flash.mode = Camera.FlashOff;
        camera.isFlashOn = false;
    }

    function syncCameraSettings() {
        camera.flash.mode = camera.isFlashOn ? Camera.FlashTorch : Camera.FlashOff;
    }

    function updateCameraState() {
        var isAppActive = Qt.application.active;
        var isPageActive = (mainPage.status === PageStatus.Active);
        var isFrozen = mainPage.isFrozen;
        if (isAppActive && isPageActive && !isFrozen) {
            console.log("Starting camera");
            cameraShutdownTimer.stop();
            funcCameraOn();
            syncCameraSettings();
        } else {
            console.log("Starting the timer");
            funcFlashOff();
            cameraShutdownTimer.restart();
        }
    }

function getBestResolution() {
        // Wait for the camera hardware to be fully loaded
        if (camera.cameraStatus !== Camera.LoadedStatus && camera.cameraStatus !== Camera.ActiveStatus) {
            return;
        }

        var camPosition = camera.position;

        // Check cache first
        if (resolutionCache[camPosition]) {
            camera.viewfinder.resolution = resolutionCache[camPosition];
            console.log("Loaded cached resolution for camera: " + resolutionCache[camPosition].width + "x" + resolutionCache[camPosition].height);
            return;
        }

        var supportedRes = camera.supportedViewfinderResolutions();
        if (supportedRes.length === 0) {
            return; 
        }

        var screenRatio = Math.max(Screen.width, Screen.height) / Math.min(Screen.width, Screen.height);
        
        var bestRes = supportedRes[0];
        var smallestDifference = 9999;
        var maxAreaForBestRatio = 0;

        // Loop through resolutions
        for (var i = 0; i < supportedRes.length; i++) {
            var res = supportedRes[i];
            var resRatio = Math.max(res.width, res.height) / Math.min(res.width, res.height);
            var difference = Math.abs(resRatio - screenRatio);
            var area = res.width * res.height; // Total pixels for quality checking

            // If this ratio is significantly closer to the screen ratio (outside the 0.1 tolerance)
            if (difference < smallestDifference - 0.1) {
                smallestDifference = difference;
                bestRes = res;
                maxAreaForBestRatio = area;
            } 
            // If the ratio is roughly the same (within the 0.1 tolerance bracket)
            else if (Math.abs(difference - smallestDifference) <= 0.1) {
                // Pick the one with the higher image quality!
                if (area > maxAreaForBestRatio) {
                    smallestDifference = difference; 
                    bestRes = res;
                    maxAreaForBestRatio = area;
                }
            }
        }

        // Save to cache and apply
        resolutionCache[camPosition] = Qt.size(bestRes.width, bestRes.height);
        camera.viewfinder.resolution = resolutionCache[camPosition];
        console.log("Calculated new resolution for camera: " + bestRes.width + "x" + bestRes.height);
    }

    allowedOrientations: Orientation.Portrait
    // What happens when the page is changed
    onStatusChanged: updateCameraState()
    onIsFrozenChanged: updateCameraState()
    Component.onCompleted: updateCameraState()

    ShareAction {
        id: shareAction

        resources: [mainPage.savedImagePath]
        mimeType: "image/png"
    }

    Notification {
        id: saveNotification

        appName: "Tarkka"
        icon: "image://theme/icon-m-image"
        isTransient: false
        remoteActions: [{
            "name": "default",
            "service": "com.jolla.gallery",
            "path": "/com/jolla/gallery/ui",
            "iface": "com.jolla.gallery.ui",
            "method": "showimage",
            "arguments": ["file://" + mainPage.savedImagePath]
        }, {
            "name": "share",
            "displayName": qsTr("Share"),
            "icon": "icon-s-share"
        }, {
            "name": "open",
            "displayName": qsTr("Open"),
            "service": "com.jolla.gallery",
            "path": "/com/jolla/gallery/ui",
            "iface": "com.jolla.gallery.ui",
            "method": "showimage",
            "arguments": ["file://" + mainPage.savedImagePath]
        }]
        onClicked: {
            console.log("Triggered opening of " + mainPage.savedImagePath);
            Qt.openUrlExternally("file://" + mainPage.savedImagePath);
        }
        onActionInvoked: {
            if (name === "open") {
                console.log("Triggered opening of " + mainPage.savedImagePath);
                Qt.openUrlExternally("file://" + mainPage.savedImagePath);
            } else if (name === "share") {
                console.log("Triggered sharing of " + mainPage.savedImagePath);
                shareAction.trigger();
            }
        }
    }

    Camera {
        id: camera

        property bool isFlashOn: false

        captureMode: Camera.CaptureVideo
        cameraState: Camera.UnloadedState
        //viewfinder.resolution: "1920x1080"

        focus {
            focusMode: Camera.FocusContinuous
        }

// Trigger our calculation when the camera backend is ready
        onCameraStatusChanged: {
            if (cameraStatus === Camera.LoadedStatus || cameraStatus === Camera.ActiveStatus) {
                mainPage.getBestResolution();
            }
            }

    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height
        interactive: !mainPage.isFrozen

        PushUpMenu {
            enabled: !mainPage.isFrozen
            visible: !mainPage.isFrozen

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

            CameraFilterShader {
                id: shaderView

                anchors.fill: parent
                visible: !mainPage.isFrozen
                // Pass the variables to the shader
                filterType: mainPage.currentFilter
                brightness: mainPage.brightnessValue
                contrast: mainPage.contrastValue

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
                property real sensitivity: 2

                anchors.fill: parent
                onPinchStarted: {
                    if (mainPage.isFrozen)
                        initialScale = frozenView.scale;
                    else if (camera.cameraState === Camera.ActiveState)
                        initialZoom = floatingControls.activeZoom;
                }
                onPinchUpdated: {
                    if (mainPage.isFrozen) {
                        floatingControls.frozenZoom = Math.max(1, Math.min(initialScale * pinch.scale, 4));
                    } else if (camera.cameraState === Camera.ActiveState) {
                        var sensitivity = 10;
                        var delta = (pinch.scale - 1) * sensitivity;
                        var newZoom = initialZoom + delta;
                        var maxZoom = camera.maximumDigitalZoom > 1 ? camera.maximumDigitalZoom : 4;
                        floatingControls.activeZoom = Math.max(1, Math.min(newZoom, maxZoom));
                    }
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
                            focusIndicator.showAt(mouse.x, mouse.y);
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

            FocusRing {
                id: focusIndicator

                cameraObj: camera
            }

        }

        // Floating controls
        CameraControlPanel {
            id: floatingControls

            anchors.bottom: controlOverlay.top
            anchors.bottomMargin: Theme.paddingLarge
            isFrozen: mainPage.isFrozen
            cameraObj: camera
            onFlashClicked: {
                camera.isFlashOn = !camera.isFlashOn;
                syncCameraSettings();
            }
            onFrozenZoomChanged: {
                if (mainPage.isFrozen)
                    frozenView.scale = floatingControls.frozenZoom;

            }
            onFreezeClicked: {
                shaderView.grabToImage(function(result) {
                    mainPage.lastFreezeFrame = result;
                    frozenView.source = result.url;
                    mainPage.isFrozen = true;
                });
            }
            onUnfreezeClicked: {
                mainPage.isFrozen = false;
                frozenView.scale = 1;
                imageFlickable.contentX = 0;
                imageFlickable.contentY = 0;
            }
            onSaveClicked: {
                if (mainPage.lastFreezeFrame) {
                    floatingControls.isSaving = true;
                    var timestamp = new Date().getTime();
                    var fileName = "Tarkka_" + timestamp + ".png";
                    mainPage.savedImagePath = StandardPicturesPath + "/" + fileName;
                    console.log("Saving in: " + mainPage.savedImagePath);
                    var success = mainPage.lastFreezeFrame.saveToFile(mainPage.savedImagePath);
                    if (success) {
                        saveNotification.icon = mainPage.savedImagePath;
                        saveNotification.summary = qsTr("Image saved");
                        saveNotification.body = qsTr("Image saved in the gallery as ") + fileName;
                        saveNotification.publish();
                        console.log("Image saved in: " + mainPage.savedImagePath);
                    } else {
                        saveNotification.icon = "image://theme/icon-splus-error";
                        saveNotification.summary = qsTr("Error");
                        saveNotification.body = qsTr("Error saving the image in the gallery");
                        saveNotification.publish();
                        console.log("Image cannot be saved");
                    }
                    floatingControls.isSaving = false;
                }
            }
            onShareClicked: {
                if (mainPage.lastFreezeFrame) {
                    floatingControls.isSharing = true;
                    var tempPath = AppCachePath + "/tarkka_share_temp.png";
                    var success = mainPage.lastFreezeFrame.saveToFile(tempPath);
                    console.log("Sharing: file://" + tempPath);
                    if (success) {
                        shareAction.resources = ["file://" + tempPath];
                        shareAction.trigger();
                    } else {
                        console.log("Error during sharing.");
                    }
                    floatingControls.isSharing = false;
                }
            }
        }

        Rectangle {
            id: controlOverlay

            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.itemSizeLarge + (Theme.paddingMedium * 2)
            color: Theme.rgba(Theme.overlayBackgroundColor, 0.7)
            opacity: mainPage.isFrozen ? 0 : 1

            OverlayButton {
                id: filterIndicatorIcon

                icon.source: {
                    if (viewMode === 1)
                        return "image://theme/icon-m-day";

                    if (viewMode === 2)
                        return "image://theme/icon-m-light-contrast";

                    return "image://theme/icon-camera-filter-off";
                }
            }

            // Filters
            FilterList {
                id: filterListView

                anchors.left: filterIndicatorIcon.right
                anchors.right: parent.right
                height: parent.height
                visible: viewMode === 0
                currentFilter: mainPage.currentFilter
                onCurrentFilterChanged: mainPage.currentFilter = currentFilter
            }

            // Brightness slider
            AdjustSlider {
                anchors.left: filterIndicatorIcon.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: viewMode === 1
                value: mainPage.brightnessValue
                onValueChanged: mainPage.brightnessValue = value
            }

            // Contrast slider
            AdjustSlider {
                anchors.left: filterIndicatorIcon.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: viewMode === 2
                value: mainPage.contrastValue
                onValueChanged: mainPage.contrastValue = value
            }

        }

        // Unload camera hardware when not in use
        Connections {
            target: Qt.application
            onActiveChanged: updateCameraState()
        }

    }

    Timer {
        id: cameraShutdownTimer

        interval: 1500 // 1.5 seconds
        repeat: false
        onTriggered: {
            console.log("Timer expired. Camera off");
            mainPage.funcCameraOff();
        }
    }

}
