pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland

Rectangle {
    id: workspace
    required property var modelData
    required property var root
    required property Item dragOverlay

    property var workspaceData: modelData
    property string name: workspaceData?.name ?? ""
    property var toplevels: workspaceData?.toplevels?.values.filter(t => t.lastIpcObject && t.lastIpcObject.at && t.lastIpcObject.size) ?? []
    property var isSpecial: workspace.name.includes("special:")

    border.color: !workspace.isSpecial ? root.config.workspaceBorderColor : root.config.specialWorkspaceBorderColor
    radius: root.config.globalRadius
    color: dropArea.containsDrag ? root.config.workspaceContainsDragColor : root.config.workspaceColor

    implicitWidth: root.currentMonitor ? (root.currentMonitor?.width / (root.workspaces.length + 1)) * root.config.zoom : 1
    implicitHeight: root.currentMonitor ? (root.currentMonitor?.height / (root.workspaces.length + 1)) * root.config.zoom : 1

    property int minX: toplevels.length ? Math.min(...toplevels.map(t => t.lastIpcObject.at[0] - workspace.root.config.workspacePadding)) : 0
    property int minY: toplevels.length ? Math.min(...toplevels.map(t => t.lastIpcObject.at[1] - workspace.root.config.workspacePadding)) : 0
    property int maxX: toplevels.length ? Math.max(...toplevels.map(t => t.lastIpcObject.at[0] + workspace.root.config.workspacePadding + (t.lastIpcObject.size[0] || 1))) : 1
    property int maxY: toplevels.length ? Math.max(...toplevels.map(t => t.lastIpcObject.at[1] + workspace.root.config.workspacePadding + (t.lastIpcObject.size[1] || 1))) : 1

    property real scaleX: width / (maxX - minX)
    property real scaleY: height / (maxY - minY)

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: mouse => {
            workspace.root.log(workspace.root.currentWorkspace.id, workspace.workspaceData.id);
            if (workspace.root.currentWorkspace.id == workspace.workspaceData.id)
                return;
            if (workspace.isSpecial) {
                if (Hyprland.usingLua) {
                    Hyprland.dispatch(`hl.dsp.workspace.toggle_special("${workspace.name.replace(/^special:/, "")}")`);
                } else {
                    Hyprland.dispatch(`togglespecialworkspace ${workspace.name.replace(/^special:/, "")}`);
                }
            } else {
                if (Hyprland.usingLua) {
                    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspace.workspaceData.id} })`);
                } else {
                    Hyprland.dispatch(`workspace ${workspace.workspaceData.id}`);
                }
            }
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent

        onDropped: event => {
            const src = event.source;
            if (!src)
                return;
            src.parent = parent;
            src.x = Qt.binding(() => src.isFullscreen ? (workspace.width - workspace.root.config.iconSize) / 2 : ((src.at[0] ?? 0) - workspace.minX) * workspace.scaleX);
            src.y = Qt.binding(() => src.isFullscreen ? (workspace.height - workspace.root.config.iconSize) / 2 : ((src.at[1] ?? 0) - workspace.minY) * workspace.scaleY);
            var address = src.address;
            var name = src.name;

            if (src.parent.name && src.parent.isSpecial) {
                if (Hyprland.usingLua) {
                    Hyprland.dispatch(`hl.dsp.window.move({ workspace = "${src.parent.workspaceData.name}", window = "address:${address}", follow = false })`);
                } else {
                    Hyprland.dispatch(`movetoworkspacesilent ${src.parent.workspaceData.name}, address:${address}`);
                }
                workspace.root.log(`Special: ${src.parent.workspaceData.name}`);
            } else {
                if (Hyprland.usingLua) {
                    Hyprland.dispatch(`hl.dsp.window.move({ workspace = "${src.parent.workspaceData.id}", window = "address:${address}", follow = false })`);
                } else {
                    Hyprland.dispatch(`movetoworkspacesilent ${workspace.workspaceData.id}, address:${address}`);
                }
            }
            Hyprland.refreshToplevels();
            workspace.root.log(`Moved ${name} -> workspace ${workspace.workspaceData.id}`);
        }
    }

    Repeater {
        model: workspace.workspaceData?.toplevels ?? []
        delegate: WindowItem {
            root: workspace.root
            workspace: workspace
            dragOverlay: workspace.dragOverlay
        }
    }
}
