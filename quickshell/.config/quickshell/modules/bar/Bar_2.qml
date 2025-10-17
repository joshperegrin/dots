import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

PanelWindow {
    id: panel

    anchors.top: true
    anchors.left: true
    anchors.right: true

    height: 18
    color: "transparent"


    aboveWindows: true
    exclusiveZone: (panel.show)? 15 : 0
    Behavior on exclusiveZone { NumberAnimation { duration: 100 } }

    property bool show: true // white if true, black if false
    property string font_color: (panel.show)? "white" : "transparent"
    property string bar_color: (panel.show)? "#88111111" : "transparent"
    property string font_family: "JetBrainsMono Nerd Font" 
  
    PwObjectTracker { objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] } 

    IpcHandler {
        target: "panel"
        function toggleTransparency(): void { panel.show = !panel.show }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: () => {
            dateProc.running = true
            batteryProc.running = true
            wifiProc.running = true
        }
    }

    // Center Bar
    Rectangle {
        id: centerBar
        width: 650
        height: 18


        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        bottomLeftRadius: 10
        bottomRightRadius: 10

        color: (panel.show)? "#88111111" : "transparent"

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }

        // Date - Time
        Text {
            id: dateText

            property string dateString: ""

            text: dateString
            font.family: panel.font_family
            font.pointSize: 8

            color: panel.font_color

            anchors.centerIn: parent

            Behavior on color { ColorAnimation { duration: 200 } }

            Process {
                id: dateProc
                command: ["date", "+%a %d %b %Y | %I:%M %p"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: dateText.dateString = text
                }
            }
        }


        Rectangle {
            width: parent.height - 5
            height: parent.height - 5

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5

            color: "transparent"
            Text {
                text: mic
                font.family: panel.font_family
                font.pointSize: 9
                anchors.centerIn: parent
                color: panel.font_color
                Behavior on color { ColorAnimation { duration: 200 } }
                property string mic: (Pipewire.defaultAudioSource?.audio.muted)? "" : ""
            }
            MouseArea {
                height: parent.height
                width: parent.width
                hoverEnabled: true
                onEntered: {hover_text.currentActive = 1}
                onExited: {hover_text.currentActive = 0}
            }
        }
        Rectangle {
            width: parent.height - 5
            height: parent.height - 5
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10 + parent.height-5
            Text {
                text: volumeString
                font.family: panel.font_family
                anchors.centerIn: parent
                color: panel.font_color
                Behavior on color { ColorAnimation { duration: 200 } }
                property string v: Pipewire.defaultAudioSink?.audio.volume * 100
                property string volumeString: (Pipewire.defaultAudioSink?.audio.muted)? "" : (v < 25)? "": (v<65)? "" : ""
            }
            MouseArea {
                height: parent.height
                width: parent.width
                hoverEnabled: true
                onEntered: {hover_text.currentActive = 2}
                onExited: {hover_text.currentActive = 0}
            }
        }
        Rectangle {
            width: parent.height - 5
            height: parent.height - 5
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: (7 + parent.height-5)*2
            Text {
                id: statusText
                text: batteryLevel
                font.family: panel.font_family
                anchors.centerIn: parent
                color: panel.font_color
                property string v: Pipewire.defaultAudioSink?.audio.volume
                property string volumeString: (Pipewire.defaultAudioSink?.audio.muted)? "" : (v < 25)? "": (v<65)? "" : ""
                Behavior on color { ColorAnimation { duration: 200 } }
                property string batteryLevel: "-1"
                property string battString: "-1"
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
                            statusText.battString = batt
                            var icon = ""
                            if (lines[1] == "Charging") {
                                if (batt < 10) { icon = "󰢜" }
                                else if (batt < 20) { icon = "󰂆" }
                                else if (batt < 30) { icon = "󰂇" }
                                else if (batt < 40) { icon = "󰂈" }
                                else if (batt < 50) { icon = "󰢝" }
                                else if (batt < 60) { icon = "󰂉" }
                                else if (batt < 70) { icon = "󰢞" }
                                else if (batt < 80) { icon = "󰂊" }
                                else if (batt < 90) { icon = "󰂋" }
                                else if (batt <= 100) { icon = "󰂄" }
                            } else {
                                if (batt < 10) { icon = "󱃍" }
                                else if (batt < 20) { icon = "󰁺" }
                                else if (batt < 30) { icon = "󰁼" }
                                else if (batt < 40) { icon = "󰁽" }
                                else if (batt < 50) { icon = "󰁾" }
                                else if (batt < 60) { icon = "󰁿" }
                                else if (batt < 70) { icon = "󰂀" }
                                else if (batt < 80) { icon = "󰂁" }
                                else if (batt < 90) { icon = "󰂂" }
                                else if (batt <= 100) { icon = "󰁹" }
                            }
                            statusText.batteryLevel = `${icon}`
                        })()
                
                    }
                }
            }
            MouseArea {
                height: parent.height
                width: parent.width
                hoverEnabled: true
                onEntered: {hover_text.currentActive = 3}
                onExited: {hover_text.currentActive = 0}
            }
        }
        Rectangle {
            width: parent.height - 5
            height: parent.height - 5
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: (7 + parent.height-5)*3
            Text {
                id: wifiStatus
                text: wifiString
                font.family: panel.font_family
                anchors.centerIn: parent
                color: panel.font_color
                property string v: Pipewire.defaultAudioSink?.audio.volume
                property string volumeString: (Pipewire.defaultAudioSink?.audio.muted)? "" : (v < 25)? "": (v<65)? "" : ""
                Behavior on color { ColorAnimation { duration: 200 } }
                property string wifiString: "-1"
                property string netName: "-1"
                Process {
                    id: wifiProc
                    command: [ "/home/josh/bin/get-wifi.sh" ]
                    running: true

                    stdout: StdioCollector {
                        id: stdout2
                        onStreamFinished: (function(){
                            let lines = stdout2.text.trim().split(' ')
                            var strength = parseInt(lines[0])
                            wifiStatus.netName = lines[1]
                            var is_online = (lines[2] == "online")
                            if (strength == -1) {   
                                wifiStatus.wifiString = "󰤮"
                                return
                            }
                            if (is_online) {
                                if (strength < 10) { wifiStatus.wifiString = "󰤯"}
                                else if (strength < 25) { wifiStatus.wifiString = "󰤟"}
                                else if (strength < 50) { wifiStatus.wifiString = "󰤢"}
                                else if (strength < 75) { wifiStatus.wifiString = "󰤥"}
                                else if (strength < 100) { wifiStatus.wifiString = "󰤨"}
                            } else {
                                if (strength < 10) { wifiStatus.wifiString = "󰤫"}
                                else if (strength < 25) { wifiStatus.wifiString = "󰤠"}
                                else if (strength < 50) { wifiStatus.wifiString = "󰤣"}
                                else if (strength < 75) { wifiStatus.wifiString = "󰤦"}
                                else if (strength < 100) { wifiStatus.wifiString = "󰤩"}
                            }
                        })()
                
                    }
                }
            }
            MouseArea {
                height: parent.height
                width: parent.width
                hoverEnabled: true
                onEntered: {hover_text.currentActive = 4}
                onExited: {hover_text.currentActive = 0}
            }
        }
        Text {
            id: player
            text: (Mpris.players.values[0])? playing : " Arch Linux"
            anchors.left: parent.left
            anchors.leftMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            color: panel.font_color
            font.family: panel.font_family
            font.pointSize: 8
            Behavior on color { ColorAnimation { duration: 200 } }
            
            property string title: Mpris.players.values[0]?.trackTitle
            property string playing: (Mpris.players.values[0]?.isPlaying)? " " + title : " " + title 

            MouseArea {
                height: player.height + 10
                width: player.width + 10
                onClicked: (function(){
                    Mpris.players.values[0]?.togglePlaying()
                })()
            }
            
        }
    }

    Text {
        id: hover_text
        text: sourceString + sinkString + battString + netString
        font.family: panel.font_family
        color: panel.font_color
        font.pointSize: 8
        anchors.left: centerBar.right
        anchors.leftMargin: 5
        anchors.verticalCenter: centerBar.verticalCenter

        property int currentActive: 0
        property string sourceString: (currentActive == 1)? source : "" 
        property string source: (!Pipewire.defaultAudioSource?.audio.muted)? "Source: " + (Math.trunc(Pipewire.defaultAudioSource?.audio.volume * 100) + "% [" + Pipewire.defaultAudioSource?.description + "]"): "Source: Muted ["  + Pipewire.defaultAudioSource?.description + "]"
        property string sinkString: (currentActive == 2)? sink : "" 
        property string sink: (!Pipewire.defaultAudioSink?.audio.muted)?  "Sink: " + (Math.trunc(Pipewire.defaultAudioSink?.audio.volume * 100) + "% [" + Pipewire.defaultAudioSink?.description + "]") :  "Sink: Muted ["  + (Pipewire.defaultAudioSink?.description) + "]"
        property string battString: (currentActive == 3)? "Battery: " + statusText.battString + "%" : ""
        property string netString: (currentActive == 4)? "Network: " + wifiStatus.netName : ""
    }

}
