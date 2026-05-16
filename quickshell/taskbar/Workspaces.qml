import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import ".."

RowLayout {
    id: workspaces
    spacing: 3
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter

    readonly property string screenName: taskbar.screen?.name ?? ""
    readonly property bool usingHyprland: Hyprland.requestSocketPath !== ""

    readonly property var hyprMonitor: usingHyprland && screenName !== ""
        ? Hyprland.monitorFor(taskbar.screen)
        : null

    readonly property var currentWorkspaces: {
        if (!usingHyprland)
            return [];
        const all = Hyprland.workspaces.values;
        if (!all || all.length === 0)
            return [];
        const filtered = all.filter(w => w && workspaceOnScreen(w));
        return filtered.length > 0 ? filtered : all.filter(w => w);
    }

    function workspaceOnScreen(workspace) {
        if (!workspace)
            return false;
        if (!workspace.monitor)
            return true;
        if (hyprMonitor && workspace.monitor.id === hyprMonitor.id)
            return true;
        return workspace.monitor.name === screenName;
    }

    function workspaceLabel(workspace) {
        if (!workspace)
            return "";
        if (workspace.name && workspace.name !== "")
            return workspace.name;
        return workspace.id;
    }

    function focusedWorkspaceId() {
        if (!Hyprland.focusedWorkspace)
            return -1;
        return Hyprland.focusedWorkspace.id;
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!workspaces.usingHyprland)
                return;
            const n = event.name;
            if (n === "workspace" || n === "workspacev2" || n === "focusedmon" || n === "monitorremoved" || n === "monitoradded")
                Hyprland.refreshWorkspaces();
        }
    }

    Repeater {
        model: workspaces.currentWorkspaces

        Button {
            id: control
            required property var modelData

            anchors.centerIn: parent.centerIn

            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: workspaces.workspaceLabel(modelData)
                font.family: fontMonaco.name
                width: 10
                height: 10
                font.pixelSize: Config.settings.bar.fontSize
                color: Config.colors.text
            }

            onPressed: event => {
                if (modelData)
                    modelData.activate();
                event.accepted = true;
            }

            NewBorder {
                commonBorderWidth: 2
                commonBorder: false
                lBorderwidth: -2
                rBorderwidth: 0
                tBorderwidth: -4
                bBorderwidth: -1
                borderColor: Config.colors.outline
                zValue: -1
            }

            function getColor() {
                const focusedId = workspaces.focusedWorkspaceId();
                if (modelData?.urgent)
                    return Config.colors.urgent;
                if (modelData && (modelData.id === focusedId || mouse.hovered))
                    return Config.colors.shadow;
                return Config.colors.base;
            }

            background: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                border.width: 1
                border.color: Config.colors.outline
                width: 22
                height: 22
                color: control.getColor()
            }

            HoverHandler {
                id: mouse
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
