pragma Singleton

import Nemo.Configuration 1.0
import QtQuick 2.0

Item {
    id: root

    signal filterVisibilityChanged()

    readonly property string defaultOrder: "0,1,2,3,4,5,6,7,8,9,10,11,12,13"
    readonly property alias orderedFilters: orderModel
    readonly property alias visibleFilterModel: visibleModel

    ConfigurationValue {
        id: hiddenConfig

        key: "/apps/harbour-tarkka/hidden_filters"
        defaultValue: ""

        onValueChanged: rebuildVisibleModel()
    }

    ConfigurationValue {
        id: orderConfig

        key: "/apps/harbour-tarkka/filter_order"
        defaultValue: defaultOrder

        onValueChanged: reloadOrder()
    }

    ListModel {
        id: orderModel
    }

    ListModel {
        id: visibleModel
    }

    function filterName(filterType) {
        switch (filterType) {
        case 0:
            return qsTr("No filter")
        case 1:
            return qsTr("Grayscale")
        case 2:
            return qsTr("Negative")
        case 3:
            return qsTr("Solarize")
        case 4:
            return qsTr("Whiteboard")
        case 5:
            return qsTr("Blackboard")
        case 6:
            return qsTr("Yellow on black")
        case 7:
            return qsTr("Black on yellow")
        case 8:
            return qsTr("Yellow on blue")
        case 9:
            return qsTr("Blue on yellow")
        case 10:
            return qsTr("White on blue")
        case 11:
            return qsTr("Blue on white")
        case 12:
            return qsTr("Red on black")
        case 13:
            return qsTr("Black on red")
        default:
            return ""
        }
    }

    function parseHidden(value) {
        if (!value || value.length === 0)
            return []

        return value.split(",").map(function (part) {
            return parseInt(part, 10)
        }).filter(function (id) {
            return !isNaN(id) && id !== 0
        })
    }

    function parseOrder(value) {
        var order = []
        if (value && value.length > 0) {
            order = value.split(",").map(function (part) {
                return parseInt(part, 10)
            }).filter(function (id) {
                return !isNaN(id)
            })
        }

        var seen = {}
        var normalized = []
        var i

        for (i = 0; i < order.length; i++) {
            if (order[i] === 0 || seen[order[i]])
                continue

            seen[order[i]] = true
            normalized.push(order[i])
        }

        for (i = 0; i <= 13; i++) {
            if (!seen[i]) {
                seen[i] = true
                normalized.push(i)
            }
        }

        if (normalized[0] !== 0) {
            var noneIndex = normalized.indexOf(0)
            if (noneIndex > 0)
                normalized.splice(noneIndex, 1)

            normalized.unshift(0)
        }

        return normalized
    }

    function isVisible(filterType) {
        if (filterType === 0)
            return true

        return parseHidden(hiddenConfig.value).indexOf(filterType) < 0
    }

    function setVisible(filterType, visible) {
        if (filterType === 0)
            return

        var hidden = parseHidden(hiddenConfig.value)
        var index = hidden.indexOf(filterType)

        if (visible) {
            if (index >= 0)
                hidden.splice(index, 1)
        } else if (index < 0) {
            hidden.push(filterType)
        } else {
            return
        }

        hiddenConfig.value = hidden.join(",")
    }

    function saveOrder() {
        var parts = []

        for (var i = 0; i < orderModel.count; i++)
            parts.push(orderModel.get(i).filterType)

        orderConfig.value = parts.join(",")
    }

    function resetToDefaults() {
        hiddenConfig.value = ""
        orderConfig.value = defaultOrder
    }

    function reloadOrder() {
        var order = parseOrder(orderConfig.value)

        orderModel.clear()
        for (var i = 0; i < order.length; i++) {
            var filterType = order[i]
            orderModel.append({
                "filterType": filterType,
                "name": filterName(filterType)
            })
        }

        rebuildVisibleModel()
    }

    function rebuildVisibleModel() {
        visibleModel.clear()
        for (var i = 0; i < orderModel.count; i++) {
            var entry = orderModel.get(i)
            if (isVisible(entry.filterType)) {
                visibleModel.append({
                    "filterType": entry.filterType,
                    "name": entry.name
                })
            }
        }
        filterVisibilityChanged()
    }

    function moveFilter(fromIndex, toIndex) {
        if (fromIndex === toIndex || fromIndex === 0 || toIndex === 0)
            return

        orderModel.move(fromIndex, toIndex, 1)
        saveOrder()
        rebuildVisibleModel()
    }

    Component.onCompleted: reloadOrder()
}
