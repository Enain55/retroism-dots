import QtQuick
import ".."

Item {
    id: root

    property bool isToggled: false

    implicitWidth: clockText.implicitWidth + 10
    implicitHeight: clockText.implicitHeight + 6

    signal clicked()

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Time.time
        color: root.isToggled ? Config.colors.accent : Config.colors.text
        font.pixelSize: Config.settings.bar.fontSize
        font.family: fontMonaco.name
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        cursorShape: Qt.PointingHandCursor
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: root.isToggled ? Config.colors.accent : Config.colors.outline
        opacity: root.isToggled ? 0.35 : (hoverHandler.hovered ? 0.1 : 0)
        z: -1
    }
}
