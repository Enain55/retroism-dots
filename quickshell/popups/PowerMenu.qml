import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import ".."

PopupWindow {
    id: root

    property int menuWidth: 0
    property var closeCallback: function () {}

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: parentWindow.implicitHeight
    implicitWidth: 220
    implicitHeight: 200
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            id: powerMenuFrame
            windowTitle: "Shut Down"
            windowTitleIcon: "\uf418"
            windowTitleDecorationWidth: 30

            Item {
                anchors.fill: powerMenuFrame
                anchors.margins: 18
                anchors.topMargin: frame.topOffset + 18

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    Repeater {
                        model: [
                            {
                                label: "Suspend",
                                icon: "\ue7be",
                                command: Config.settings.execCommands.suspend
                            },
                            {
                                label: "Log Out",
                                icon: "\ue9ba",
                                command: Config.settings.execCommands.logout
                            },
                            {
                                label: "Restart",
                                icon: "\ue863",
                                command: Config.settings.execCommands.reboot
                            },
                            {
                                label: "Shut Down",
                                icon: "\ue8ac",
                                command: Config.settings.execCommands.shutdown
                            }
                        ]

                        delegate: Button {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 32

                            onClicked: {
                                if (modelData.command)
                                    Quickshell.execDetached(["sh", "-c", modelData.command]);
                                root.closeCallback();
                            }

                            background: Rectangle {
                                color: Config.colors.outline
                                opacity: rowMouse.hovered ? (0.15 + (parent.pressed ? 0.15 : 0)) : 0.05
                                border.width: 1
                                border.color: Config.colors.outline
                            }

                            contentItem: RowLayout {
                                spacing: 8
                                anchors.left: parent.left
                                anchors.leftMargin: 8

                                Text {
                                    font.family: iconFont.name
                                    font.pixelSize: 18
                                    color: Config.colors.text
                                    text: modelData.icon
                                }
                                Text {
                                    Layout.fillWidth: true
                                    font.family: fontMonaco.name
                                    font.pixelSize: 13
                                    color: Config.colors.text
                                    text: modelData.label
                                }
                            }

                            HoverHandler {
                                id: rowMouse
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
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

    function openPowerMenu() {
        closeAnimation.stop();
        root.visible = true;
        frame.opacity = 0;
        openAnimation.start();
    }

    function closePowerMenu() {
        openAnimation.stop();
        closeAnimation.start();
    }
}
