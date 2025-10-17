import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Hyprland

PanelWindow {
    id: panel

    anchors.top: true
    anchors.left: true
    anchors.right: true

    aboveWindows: true
    height: 18
    exclusiveZone: 0
    
    color: "transparent"
    property bool bar_color: true // white if true, black if false

        
    Rectangle {
        id: centerIsland
        height: 16
        width: row_workspaces.width + 10
        anchors.horizontalCenter: parent.horizontalCenter

        radius: 100
        color: "transparent"
        border.color: "transparent"

        Row {
            id: row_workspaces
            spacing: 5
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 5

            Repeater {
                id: workspaceRepeater
                model: Hyprland.workspaces.values.filter(w => w.toplevels.values.length > 0 || w.focused)
                
                property color original_active_color: "#4a9eff"
                property color active_color: original_active_color
                
                Rectangle {
                    id: workspace_stuff
                    width: modelData.is_active ? parent.height * 1.5 : parent.height * 1.1
                    height: parent.height - 2
                    radius: 1000
                    color: modelData.active ? workspaceRepeater.active_color : panel.bar_color ? "#3fffffff" : "#3f000000"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    MouseArea {
                        height: workspace_stuff.height + 5
                        anchors.left: parent.left
                        anchors.right: parent.right
                        onClicked: Hyprland.dispatch("workspace " + modelData.id)
                    }
                }
                
                
            }
        }
        Timer {
            id: colorResetTimer
            interval: 150 
            onTriggered: {
                workspaceRepeater.active_color = workspaceRepeater.original_active_color
            }
        }
        Connections {
            target: Hyprland
            function onRawEvent(event) {
                let eventName = event.name;

                switch(eventName) {
                    case "workspacev2": {
                        workspaceRepeater.active_color = "#137cf4"
                        colorResetTimer.restart()
                        break;
                    }
                }
            }
        }
    }

    Text {
        id: statusText
        text: batteryLevel + dateString
        color: (bar_color)? "white" : "#db000000"
        font.family: "JetBrainsMono Nerd Font"
        font.pointSize: 9

        anchors.right: parent.right
        anchors.rightMargin: 10

        property string batteryLevel: "-1"
        property string dateString: ""

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: () => {
                dateProc.running = true
                batteryProc.running = true
            }
        }
        Process {
            id: dateProc
            command: [
                "bash",
                "-c",
                "d=$(date +%-d); s=th; [[ $d -eq 11 || $d -eq 12 || $d -eq 13 ]] || case $((d % 10)) in 1) s=st;; 2) s=nd;; 3) s=rd;; esac; date +\"%I:%M %p - %a %b ${d}${s}\""
            ]
            running: true

            stdout: StdioCollector {
                onStreamFinished: statusText.dateString = text
            }
        }
        Process {
            id: batteryProc
            command: [
                "cat",
                "/sys/class/power_supply/BAT1/capacity",
                "/sys/class/power_supply/BAT1/status"
            ]
            running: true

            stdout: StdioCollector {
                id: stdout1
                onStreamFinished: (function(){
                    let lines = stdout1.text.trim().split('\n')
                    var batt = parseInt(lines[0])
                    let status = (lines[1] == "Charging")? "+" : ""
                    statusText.batteryLevel = `${status}${batt}% - `
                })()
                
            }
        }

    }
    MouseArea {
        z: -1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 5
        onClicked: panel.bar_color = !panel.bar_color
    }
}
