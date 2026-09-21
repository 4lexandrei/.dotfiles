pragma ComponentBehavior: Bound
import "components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

PanelWindow { // qmllint disable uncreatable-type
    id: root
    property bool layoutReady: currentMonitor !== null && workspaces.length > 0 && workspacesContainer.width > 0 && workspacesContainer.height > 0

    visible: layoutReady
    color: "transparent"
    focusable: true
    property bool debug: true

    readonly property var defaultConfig: ({
            position: "center",
            workspaceGridColumns: null,
            totalWorkspaces: 5,
            globalRadius: 5,
            iconSize: 32,
            zoom: 1,
            toplevelPadding: 15,
            workspaceContainerSpacing: 5,
            workspacePadding: 10,
            workspacesBackgroundColor: "#1B1B1B",
            workspaceColor: "transparent",
            workspaceBorderColor: "#32302F",
            workspaceContainsDragColor: "#32302F",
            specialWorkspaceBorderColor: "#32302F",
            windowColor: "#504945",
            fullscreenWindowColor: "transparent",
            textColor: "#D4BE98",
            tooltipBackgroundColor: "#32302F",
            enabledRandomWindowColor: false,
            displayWindowTitle: false,
            // iconFallback:
            //   - true   -> return empty string when no icon is found
            //   - false  -> return default "missing texture" placeholder icon
            //   - string -> return given custom fallback path instead
            iconFallback: true,
            showTooltip: false
        })

    FileView {
        id: configJsonFile
        path: Qt.resolvedUrl("./config.json")
        watchChanges: true
        blockLoading: true
        onFileChanged: configReloadTimer.restart()
    }
    Timer {
        id: configReloadTimer
        interval: 50
        repeat: false
        onTriggered: configJsonFile.reload()
    }
    readonly property var config: configJsonFile.text().trim() !== "" ? JSON.parse(configJsonFile.text()) : defaultConfig

    function log(...args) {
        if (debug)
            console.log(...args);
    }

    function getAppIcon(name: string, opt: var): string {
        const icon = DesktopEntries.heuristicLookup(name)?.icon;
        if (typeof opt === "boolean") {
            opt = !opt;
            // true and icon not found -> return empty string
            // false and icon not found -> return "missing texture" icon
            return Quickshell.iconPath(icon, opt);
        }
        if (typeof opt === "string")
            return Quickshell.iconPath(icon, opt);
        return Quickshell.iconPath(icon);
    }

    function computeWorkspaces(workspaces: var, totalWorkspaces: int): var {
        let base = Array.from(workspaces || []).filter(w => w.id > 0);
        for (let i = 1; i <= totalWorkspaces; ++i)
            if (!base.some(w => w.id === i))
                base.push({
                    id: i
                });
        base.sort((a, b) => a.id - b.id);
        let specials = Array.from(workspaces || []).filter(w => w.id < 0);
        return base.concat(specials);
    }

    property var activeWorkspaces: Hyprland.workspaces.values
    property var currentMonitor: Hyprland.focusedMonitor
    property var currentWorkspace: Hyprland.focusedWorkspace
    property var windowColors: ({})
    property var workspaces: computeWorkspaces(activeWorkspaces, config.totalWorkspaces)

    implicitWidth: workspacesContainer.width + config.toplevelPadding
    implicitHeight: workspacesContainer.height + config.toplevelPadding

    anchors {
        top: root.config.position.includes("top")
        right: root.config.position.includes("right")
        left: root.config.position.includes("left")
        bottom: root.config.position.includes("bottom")
    }

    Component.onCompleted: {
        log("Loaded config: " + (configJsonFile.text().trim() !== "" ? configJsonFile.path.replace(/^file:\/\//, "") : "default"));
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            Hyprland.refreshToplevels();
        }
    }

    Connections {
        target: DesktopEntries
    }

    Item {
        focus: true
        Keys.onPressed: event => {
            if (event.key == Qt.Key_Escape) {
                Qt.quit();
            }
        }
    }

    Item {
        id: dragOverlay
        anchors.fill: parent
        z: 99
    }

    Rectangle {
        id: workspacesBackground
        anchors.centerIn: parent
        color: root.config.workspacesBackgroundColor
        radius: root.config.globalRadius
        implicitWidth: parent.width
        implicitHeight: parent.height

        GridLayout {
            id: workspacesContainer
            anchors.centerIn: parent
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: root.config.workspaceGridColumns > 0 ? root.config.workspaceGridColumns : (root.anchors.right || root.anchors.left) ? 1 : root.workspaces.length
            columnSpacing: root.config.workspaceContainerSpacing
            rowSpacing: root.config.workspaceContainerSpacing

            Repeater {
                model: root.workspaces

                delegate: ColumnLayout {
                    id: workspacesColumn
                    required property var modelData

                    WorkspaceItem {
                        id: workspace
                        root: root
                        modelData: parent.modelData
                        dragOverlay: dragOverlay
                    }
                }
            }
        }
    }
}
