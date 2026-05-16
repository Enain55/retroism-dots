import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Services.Pipewire

import ".."

Item {
    id: root

    Layout.alignment: Qt.AlignVCenter
    Layout.leftMargin: 4
    Layout.rightMargin: 6

    implicitHeight: Config.settings.bar.trayIconSize + 8
    implicitWidth: contentLayout.implicitWidth + 10

    property var audioSink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: root.audioSink ? [root.audioSink] : []
    }

    readonly property bool isMuted: root.audioSink?.audio?.muted ?? false
    readonly property real volumeLevel: root.audioSink?.audio?.volume ?? 0
    readonly property string volumeLabel: Math.round(volumeLevel * 100) + "%"

    Rectangle {
        id: background
        anchors.fill: parent
        color: Config.colors.outline
        opacity: hoverHandler.hovered || scrollArea.pressed ? (0.12 + (scrollArea.pressed ? 0.1 : 0)) : 0
        border.width: hoverHandler.hovered ? 1 : 0
        border.color: Config.colors.outline
    }

    Row {
        id: contentLayout
        spacing: 4
        anchors.centerIn: parent

        Text {
            font.family: iconFont.name
            font.pixelSize: Config.settings.bar.fontSize + 2
            color: Config.colors.text
            text: root.isMuted ? "\ue04f" : "\ue050"
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            font.family: fontMonaco.name
            font.pixelSize: Config.settings.bar.fontSize
            color: Config.colors.text
            text: root.volumeLabel
            verticalAlignment: Text.AlignVCenter
        }
    }

    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        cursorShape: Qt.PointingHandCursor
    }

    MouseArea {
        id: scrollArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property real scrollStep: 0.03

        onClicked: event => {
            if (!root.audioSink?.audio)
                return;
            if (event.button === Qt.LeftButton)
                root.audioSink.audio.muted = !root.audioSink.audio.muted;
        }

        onWheel: event => {
            if (!root.audioSink?.audio)
                return;
            root.audioSink.audio.muted = false;
            const delta = event.angleDelta.y > 0 ? scrollStep : -scrollStep;
            root.audioSink.audio.volume = Math.max(0, Math.min(1, root.audioSink.audio.volume + delta));
        }
    }
}
