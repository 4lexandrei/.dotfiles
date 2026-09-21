pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland

Rectangle {
    id: window
    required property var modelData
    required property var root
    required property Item dragOverlay
    property var workspace

    property var windowData: modelData
    property string name: windowData.lastIpcObject?.class ?? ""
    property string address: windowData.lastIpcObject?.address ?? ""
    property var at: windowData.lastIpcObject?.at ?? [0, 0]
    property var size: windowData.lastIpcObject?.size ?? [1, 1]
    property bool isFullscreen: windowData.lastIpcObject?.fullscreen ?? false

    property bool displayIcon: window.width >= 16 && window.height >= 16
    property bool displayTitle: window.root.config.displayWindowTitle && window.width >= window.root.config.iconSize && window.height >= window.root.config.iconSize

    property Item initialParent: parent
    property int initialX: 0
    property int initialY: 0

    radius: window.root.config.globalRadius ?? 0
    color: {
        if (isFullscreen) {
            return window.root.config.fullscreenWindowColor;
        }
        if (window.root.config.enabledRandomWindowColor) {
            if (!(address in root.windowColors))
                root.windowColors[address] = Qt.rgba(Math.random(), Math.random(), Math.random(), 0.8);
            return root.windowColors[address];
        } else {
            return window.root.config.windowColor;
        }
    }

    // TODO: Fullscreen windows size should take the remaning space of the workspace
    // Either by being able to query last size and position of fullscreened windows

    // NOTE: (Current behaviour)
    // Another option would be setting window size equals to the icon and center it
    // allowing users to also drag windows beneath it

    x: isFullscreen ? (workspace.width - window.root.config.iconSize) / 2 : ((at[0] ?? 0) - workspace.minX) * workspace.scaleX
    y: isFullscreen ? (workspace.height - window.root.config.iconSize) / 2 : ((at[1] ?? 0) - workspace.minY) * workspace.scaleY
    z: isFullscreen ? 99 : 0
    width: isFullscreen ? window.root.config.iconSize : ((size[0] ?? 50)) * workspace.scaleX
    height: isFullscreen ? window.root.config.iconSize : ((size[1] ?? 50)) * workspace.scaleY

    Drag.active: mouseArea.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    Column {
        anchors.centerIn: parent
        width: parent.width

        Image {
            id: icon
            visible: window.displayIcon
            source: window.root.getAppIcon(window.name, window.root.config.iconFallback)
            fillMode: Image.PreserveAspectFit
            sourceSize.width: window.width >= window.root.config.iconSize ? window.root.config.iconSize : window.root.config.iconSize / 2
            sourceSize.height: window.height >= window.root.config.iconSize ? window.root.config.iconSize : window.root.config.iconSize / 2
            anchors.horizontalCenter: parent.horizontalCenter
            ToolTip {
                id: windowTooltip
                text: window.windowData.title
                visible: window.root.config.showTooltip && mouseArea.containsMouse && !window.root.config.displayWindowTitle
                delay: 100

                contentItem: Text {
                    text: windowTooltip.text
                    font: windowTooltip.font
                    color: window.root.config.textColor
                }

                background: Rectangle {
                    color: window.root.config.tooltipBackgroundColor
                    border.color: "transparent"
                    radius: window.root.config.globalRadius
                }
            }
        }

        Text {
            property real textPadding: 20
            visible: window.displayTitle && !window.isFullscreen
            text: window.windowData.title ?? "?"
            color: window.root.config.textColor
            width: parent.width
            leftPadding: textPadding
            rightPadding: textPadding
            anchors.horizontalCenter: parent.horizontalCenter
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        drag.target: window
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: mouse => {
            cursorShape = Qt.ClosedHandCursor;
            window.root.log(`Initial parent: ${window.initialParent}`);
            window.root.log(`Initial position: ${window.x}, ${window.y}`);
            window.initialParent = window.parent;
            window.initialX = window.x;
            window.initialY = window.y;
            const globalPos = window.mapToItem(window.dragOverlay, 0, 0);
            window.parent = window.dragOverlay;
            window.x = globalPos.x;
            window.y = globalPos.y;
        }
        onReleased: {
            var target = window.Drag.target;
            if (!target) {
                window.parent = window.initialParent;
                window.x = Qt.binding(() => window.isFullscreen ? (window.workspace.width - window.root.config.iconSize) / 2 : ((window.at[0] ?? 0) - window.workspace.minX) * window.workspace.scaleX);
                window.y = Qt.binding(() => window.isFullscreen ? (window.workspace.height - window.root.config.iconSize) / 2 : ((window.at[1] ?? 0) - window.workspace.minY) * window.workspace.scaleY);
            }
            cursorShape = Qt.PointingHandCursor;
            window.Drag.drop();
            window.root.log(`New parent: ${window.initialParent}`);
            window.root.log(`New position: ${window.initialX}, ${window.initialY}`);
            Hyprland.refreshToplevels();
        }
    }
}
