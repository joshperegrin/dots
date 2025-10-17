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
    property bool show: true // white if true, black if false

    IpcHandler {
        target: "panel"
        function toggleTransparency(): void { panel.show = !panel.show }
    }
    Rectangle {
        width: statusText.width + 15
        radius: 10
        height: 15
        anchors.top: parent.top
        //anchors.right: parent.right
        //anchors.rightMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 2
        border.color: (panel.show)? "#4c4c4c" : "transparent"
        border.width: .5
        color: (panel.show)? "#E8111111" : "transparent"

        Behavior on border.color { ColorAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 200 } }
        Text {

            id: statusText
            text: batteryLevel + dateString
            color: (panel.show)? "white" : "transparent"
            //font.family: "JetBrainsMono Nerd Font"
            //font.family: "SpaceMono Nerd Font"
            font.family: "Adwaita Sans"
            font.pointSize: 8

            Behavior on color { ColorAnimation { duration: 200 } }

            
            anchors.centerIn: parent
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
    }
    MouseArea {
        z: -1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 5
        onClicked: panel.show = !panel.show
    }
}
