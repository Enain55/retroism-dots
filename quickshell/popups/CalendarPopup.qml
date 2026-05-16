import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import ".."

PopupWindow {
    id: root

    property int anchorX: 0
    property var closeCallback: function () {}

    anchor.window: taskbar
    anchor.rect.x: anchorX
    anchor.rect.y: parentWindow.implicitHeight
    implicitWidth: 300
    implicitHeight: 318
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20
        property int monthOffset: 0

        readonly property var today: new Date()
        readonly property var viewDate: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)
        readonly property string viewTitle: Qt.formatDateTime(viewDate, "MMMM yyyy")
        readonly property bool viewingToday: monthOffset === 0

        PopupWindowFrame {
            id: calendarFrame
            windowTitle: frame.viewTitle
            windowTitleIcon: "\ue935"
            windowTitleDecorationWidth: 40

            Item {
                anchors.fill: calendarFrame
                anchors.margins: 18
                anchors.topMargin: frame.topOffset + 18
                anchors.bottomMargin: 12

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        CalendarNavButton {
                            iconText: "\ue5cb"
                            onNavClicked: frame.monthOffset--
                        }

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 24
                            visible: !frame.viewingToday
                            onClicked: frame.monthOffset = 0

                            background: Rectangle {
                                color: Config.colors.outline
                                opacity: todayMouse.hovered ? 0.15 : 0.08
                                border.width: 1
                                border.color: Config.colors.outline
                            }

                            contentItem: Text {
                                anchors.centerIn: parent
                                font.family: fontMonaco.name
                                font.pixelSize: 11
                                color: Config.colors.text
                                text: "Today"
                            }

                            HoverHandler {
                                id: todayMouse
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            visible: frame.viewingToday
                        }

                        CalendarNavButton {
                            iconText: "\ue5cc"
                            onNavClicked: frame.monthOffset++
                        }

                        CalendarNavButton {
                            iconText: "\ue14c"
                            onNavClicked: root.requestClose()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                            delegate: Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                font.family: fontMonaco.name
                                font.pixelSize: 11
                                font.bold: true
                                color: Config.colors.text
                                text: modelData
                            }
                        }
                    }

                    GridLayout {
                        id: dayGrid
                        Layout.fillWidth: true
                        columns: 7
                        rowSpacing: 2
                        columnSpacing: 2

                        readonly property int displayMonth: frame.viewDate.getMonth()
                        readonly property int displayYear: frame.viewDate.getFullYear()
                        readonly property int firstWeekday: {
                            const d = new Date(displayYear, displayMonth, 1);
                            return d.getDay();
                        }
                        readonly property int daysInMonth: {
                            return new Date(displayYear, displayMonth + 1, 0).getDate();
                        }

                        Repeater {
                            model: 42
                            delegate: Item {
                                required property int index
                                Layout.fillWidth: true
                                implicitHeight: 26

                                readonly property int dayNumber: index - dayGrid.firstWeekday + 1
                                readonly property bool inMonth: dayNumber >= 1 && dayNumber <= dayGrid.daysInMonth
                                readonly property bool isToday: inMonth
                                    && dayNumber === frame.today.getDate()
                                    && dayGrid.displayMonth === frame.today.getMonth()
                                    && dayGrid.displayYear === frame.today.getFullYear()

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    visible: parent.inMonth
                                    color: parent.isToday ? Config.colors.accent : (dayMouse.hovered ? Config.colors.highlight : "transparent")
                                    border.width: parent.isToday ? 1 : 0
                                    border.color: Config.colors.outline
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: parent.inMonth
                                    font.family: fontMonaco.name
                                    font.pixelSize: 12
                                    color: parent.isToday ? Config.colors.highlight : Config.colors.text
                                    text: parent.dayNumber
                                }

                                MouseArea {
                                    id: dayMouse
                                    anchors.fill: parent
                                    enabled: parent.inMonth
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        Layout.topMargin: 2
                        Layout.bottomMargin: 2

                        Rectangle {
                            anchors.fill: parent
                            color: Config.colors.highlight
                            opacity: 0.35
                            border.width: 1
                            border.color: Config.colors.outline
                        }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 8
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            font.family: fontMonaco.name
                            font.pixelSize: 12
                            color: Config.colors.text
                            text: Time.time.trim()
                        }
                    }
                }
            }
        }

        OpacityAnimator {
            id: openAnimation
            target: frame
            from: 0
            to: 1
            duration: 140
            easing.type: Easing.OutCubic
        }
        OpacityAnimator {
            id: closeAnimation
            target: frame
            from: 1
            to: 0
            duration: 80
            easing.type: Easing.InOutQuad
            onFinished: root.visible = false
        }
    }

    function openCalendarPopup() {
        frame.monthOffset = 0;
        closeAnimation.stop();
        root.visible = true;
        frame.opacity = 0;
        openAnimation.start();
    }

    function closeCalendarPopup() {
        openAnimation.stop();
        closeAnimation.start();
    }

    function requestClose() {
        if (typeof closeCallback === "function")
            closeCallback();
    }

    component CalendarNavButton: Button {
        property string iconText: ""
        signal navClicked()

        implicitWidth: 28
        implicitHeight: 24
        onClicked: navClicked()

        background: Rectangle {
            color: Config.colors.outline
            opacity: navMouse.hovered ? (0.15 + (parent.pressed ? 0.1 : 0)) : 0.08
            border.width: 1
            border.color: Config.colors.outline
        }

        contentItem: Text {
            anchors.centerIn: parent
            font.family: iconFont.name
            font.pixelSize: 18
            color: Config.colors.text
            text: parent.iconText
        }

        HoverHandler {
            id: navMouse
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            cursorShape: Qt.PointingHandCursor
        }
    }
}
