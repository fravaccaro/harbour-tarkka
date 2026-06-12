import "../FilterSettings" 1.0
import Opal.Delegates 1.0 as D
import Opal.DragDrop 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root

    allowedOrientations: Orientation.All

    SilicaListView {
        id: filterList

        anchors.fill: parent
        model: FilterSettings.orderedFilters

        header: Column {
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Filters")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.WordWrap
                color: Theme.secondaryHighlightColor
                text: qsTr("No filter is always shown and stays first. Use the switches to show or hide other filters, and drag to reorder them.")
            }
        }

        ViewDragHandler {
            id: viewDragHandler

            listView: filterList
            active: true

            onItemDropped: {
                if (originalIndex === 0 || finalIndex === 0)
                    FilterSettings.reloadOrder()
                else
                    FilterSettings.saveOrder()
            }
        }

        delegate: D.OneLineDelegate {
            width: filterList.width
            interactive: false
            dragHandler: filterType === 0 ? null : viewDragHandler
            enableDefaultGrabHandle: filterType !== 0
            text: name

            leftItem: Component {
                TextSwitch {
                    checked: FilterSettings.isVisible(filterType)
                    enabled: filterType !== 0
                    down: false
                    width: Theme.iconSizeSmall
                    height: width
                    leftMargin: 0
                    rightMargin: 0

                    onCheckedChanged: {
                        if (!enabled)
                            return

                        if (checked !== FilterSettings.isVisible(filterType))
                            FilterSettings.setVisible(filterType, checked)
                    }

                    Binding {
                        target: _indicator().parent
                        property: "height"
                        value: height
                    }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset to defaults")
                onClicked: FilterSettings.resetToDefaults()
            }
        }

        VerticalScrollDecorator {
        }
    }

}
