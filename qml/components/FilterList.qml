import "../FilterSettings" 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
    id: root

    property int currentFilter: 0

    orientation: ListView.Horizontal
    spacing: Theme.paddingLarge
    clip: true
    model: FilterSettings.visibleFilterModel

    delegate: BackgroundItem {
        width: filterLabel.width + Theme.paddingLarge * 2
        height: root.height
        onClicked: root.currentFilter = filterType

        Label {
            id: filterLabel

            anchors.centerIn: parent
            text: name
            color: root.currentFilter === filterType ? Theme.highlightColor : Theme.primaryColor
        }

    }

}
