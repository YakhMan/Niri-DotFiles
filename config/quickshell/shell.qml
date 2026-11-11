import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Networking


ShellRoot{



PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30 
    color: "transparent"
    exclusiveZone: 38
}


IpcHandler {
    target: "launcher"
    function toggle() {
        
        toggleLauncher()
    }
}


     
function toggleLauncher() {
    if (appLauncherWidget.isOpen) {
        appLauncherWidget.isOpen = false
        appFadeAnimation.start()
        appHideTimer.restart()
    } else {
        appLauncherWidget.isOpen = true
        appLauncherWidget.panelVisible = true
        appCloseTimer.stop()
        appSearchField.text = ""
        appLauncherWidget.filteredApps = DesktopEntries.applications.values
        appSearchField.forceActiveFocus()
    }
}



// ---- App Launcher ----
 
Item {  

    id: appLauncherWidget
    property bool isOpen: false
    property bool panelVisible: false
    property var filteredApps: []

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            if (!appLauncherWidget.isOpen || appSearchField.text === "") {
                appLauncherWidget.filteredApps = DesktopEntries.applications.values
            }
        }
    }

    PanelWindow {
        id: appLauncherPanel
        anchors.top: true
        anchors.left: true
        margins.left: 4
        margins.top: 4
        implicitWidth: 46
        implicitHeight: 30
        color: "transparent"
        
        exclusionMode: ExclusionMode.Ignore
        focusable: true 

        Rectangle {
            id: appLauncherButton
            width: 30
            height: 30
            radius: 8
            anchors.centerIn: parent
            color: appButtonMouseArea.containsMouse ? "#96d3f8" : "#cc111111"

            Text {
                anchors.centerIn: parent
                font.family: "Symbols Nerd Font"
                text: String.fromCodePoint(0xF40E)
                font.pixelSize: 16
                font.bold: false
                color: appButtonMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
            }

            MouseArea {
                id: appButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (appLauncherWidget.isOpen) {
                        appLauncherWidget.isOpen = false
                        appFadeAnimation.start()
                        appHideTimer.restart()
                    } else {
                        appLauncherWidget.isOpen = true
                        appLauncherWidget.panelVisible = true
                        appCloseTimer.stop()
                        appSearchField.text = ""
                        appLauncherWidget.filteredApps = DesktopEntries.applications.values
                        appSearchField.forceActiveFocus()
                    }
                }
            }
        }

        
        PopupWindow {
            id: appLauncherPopup
            anchor.window: appLauncherPanel
            anchor.rect.x: 0
            anchor.rect.y: appLauncherPanel.height + 4

            visible: appLauncherWidget.panelVisible
            grabFocus: true 
            color: "transparent"
            width: 320
            height: 380

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        appCloseTimer.stop()
                    } else {
                        appCloseTimer.stop()
                    }
                }
            }

            Item {
                id: appPopupContent
                anchors.fill: parent
                opacity: 0.0

                states: State {
                    name: "visible"
                    when: appLauncherWidget.isOpen
                    PropertyChanges { target: appPopupContent; opacity: 1.0 }
                }

                transitions: Transition {
                    NumberAnimation { property: "opacity"; duration: 500; easing.type: Easing.OutQuad }
                }

                NumberAnimation on opacity {
                    id: appFadeAnimation
                    running: false
                    to: 0.0
                    duration: 500
                    easing.type: Easing.InOutQuad
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#cc111111"
                    radius: 12
                    border.color: "#333333"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                      
                        Rectangle {
                            width: parent.width
                            height: 36
                            radius: 8
                            color: "#1a1b26"
                            border.color: appSearchField.activeFocus ? "#96d3f8" : "transparent"
                            border.width: 1

                            TextInput {
                                id: appSearchField
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: TextInput.AlignVCenter
                                color: "#96d3f8"
                                font.pointSize: 10
                                font.bold:true
                                selectByMouse: true
                                focus: true 
                                
                                cursorDelegate: Rectangle {
                                    width: 1
                                    color: "#96d3f8"
                                    visible: appSearchField.cursorVisible
                                }

                                onTextChanged: {
                                    var allApps = DesktopEntries.applications.values
                                    var query = text.toLowerCase()
                                    if (query.length === 0) {
                                        appLauncherWidget.filteredApps = allApps
                                    } else {
                                        appLauncherWidget.filteredApps = allApps.filter(function(app) {
                                            return app.name.toLowerCase().includes(query)
                                        })
                                    }
                                }
                            }
                        }

                       
                        ListView {
                            width: parent.width
                            height: parent.height - 44
                            model: appLauncherWidget.filteredApps
                            clip: true
                            spacing: 4

                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 40
                                radius: 8
                                color: appItemMouseArea.containsMouse ? "#96d3f8" : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 10

                                    
                                    Item {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter

                                        IconImage {
                                            id: appIcon
                                            anchors.fill: parent
                                            source: Quickshell.iconPath(modelData.icon)
                                            visible: source !== "" && status === Image.Ready
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !appIcon.visible
                                            font.family: "Symbols Nerd Font"
                                            text: String.fromCodePoint(0xF02D) 
                                            font.pixelSize: 16
                                            color: appItemMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
                                        }
                                    }

                                    
                                    Text {
                                        text: modelData.name
                                        font.bold: true
                                        font.pointSize: 10
                                        color: appItemMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        width: parent.width - 30
                                    }
                                }

                                MouseArea {
                                    id: appItemMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.execute()
                                        appLauncherWidget.isOpen = false
                                        appFadeAnimation.start()
                                        appHideTimer.restart()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    Timer {
        id: appCloseTimer
        interval: 4000
        running: false; repeat: false
        onTriggered: {
            appLauncherWidget.isOpen = false
            appFadeAnimation.start()
            appHideTimer.restart()
        }
    }

    Timer {
        id: appHideTimer
        interval: 500
        running: false; repeat: false
        onTriggered: {
            if (!appLauncherWidget.isOpen) {
                appLauncherWidget.panelVisible = false
            }
        }
    }
}

// ---- CPU ----

PanelWindow {
    anchors.top: true
    anchors.left: true
    margins.top: 4
    margins.left: 55
    implicitWidth: 130
    implicitHeight: 30
    color: "transparent"
    
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: '#cc111111'
        implicitHeight: 30

        Text {
            id: cpuText
            anchors.centerIn: parent
            color: "#96d3f8"
            font.family: "Symbols Nerd Font"
            font.bold: true
            font.pointSize: 10
            text: "--%"

            property real prevIdle: 0
            property real prevTotal: 0
        }

        Process {
            id: cpuProc
            command: ["cat", "/proc/stat"]
            running: false

            stdout: StdioCollector {
                onStreamFinished: {
                    var lines = this.text.split("\n")
                    var parts = lines[0].trim().split(/\s+/)
                    var idle = parseInt(parts[4]) + parseInt(parts[5])
                    var total = 0
                    for (var i = 1; i < parts.length; i++) total += parseInt(parts[i])

                    if (cpuText.prevTotal > 0) {
                        var dIdle = idle - cpuText.prevIdle
                        var dTotal = total - cpuText.prevTotal
                        if (dTotal > 0)
                            cpuText.text = String.fromCodePoint(0xf4bc) + "  CPU : " + Math.round((1 - dIdle / dTotal) * 100) + "%"
                    }
                    cpuText.prevIdle = idle
                    cpuText.prevTotal = total
                }
            }
        }

        Timer {
            interval: 1500
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: cpuProc.running = true
        }
    }
}


// ---- Memory ----
PanelWindow {
    anchors.top: true
    anchors.left: true
    margins.top: 4
    margins.left: 200
    implicitWidth: 160
    implicitHeight: 30
    color: "transparent"
    
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#cc111111"
        implicitHeight: 30

        Text {
            id: ramText
            anchors.centerIn: parent
            color: "#96d3f8"
            font.pointSize: 10
            font.bold: true
            font.family: "Symbols Nerd Font"
            text: "--%"
        }

        Process {
            id: ramProc
            command: ["cat", "/proc/meminfo"]
            running: false

            stdout: StdioCollector {
                onStreamFinished: {
                    var text = this.text
                    var totalMatch = text.match(/MemTotal:\s+(\d+)/)
                    var availMatch = text.match(/MemAvailable:\s+(\d+)/)
                    if (totalMatch && availMatch) {
                        var total = parseInt(totalMatch[1])
                        var avail = parseInt(availMatch[1])
                        var pct = Math.round(((total - avail) / total) * 100)
                        ramText.text = String.fromCodePoint(0xefc5) + "  Memory : " + pct + "%"
                    }
                }
            }
        }

        Timer {
            interval: 1500
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: ramProc.running = true
        }
    }
}

// ---- Workspaces ----

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right:true
    margins.top: 4
    implicitHeight: 37
    color: "transparent"
    
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: centerIsland }

    Rectangle {
        id: centerIsland
        anchors.horizontalCenter: parent.horizontalCenter
        width: workspaceDots.implicitWidth + 24
        height: 30
        radius: 15
        color: "#cc111111"

        Item {
            id: workspaceDots
            anchors.centerIn: parent
            implicitWidth: dotRow.implicitWidth
            implicitHeight: 30

            property var workspaces: []
            property var focusedId: -1
            
            
            readonly property int maxSlots: 10

            Row {
                id: dotRow
                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    model: workspaceDots.workspaces

                    Rectangle {
                        required property var modelData
                        
                        width: modelData.is_focused ? 50 : 20
                        height: 20
                        radius: 10
                        color: modelData.is_focused ? "#96d3f8" : '#636363'

                        Text {
                            anchors.centerIn: parent
                            text: modelData.idx
                            color: modelData.is_focused ? '#030303' : '#96d3f8'
                            font.pointSize: 9
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                focusProc.command = ["niri", "msg", "action", "focus-workspace", String(modelData.idx)]
                                focusProc.running = true
                            }
                        }
                    }
                }
            }

            Process {
                id: listProc
                command: ["niri", "msg", "--json", "workspaces"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            var list = JSON.parse(this.text)
                            if (!list || list.length === 0) return
                            list.sort(function(a, b) { return a.idx - b.idx })

                            
                            var focusedIdx = -1
                            for (var i = 0; i < list.length; i++) {
                                if (list[i].is_focused) {
                                    focusedIdx = i
                                    break
                                }
                            }
                            if (focusedIdx < 0) return

                            var visibleList = []
                            var total = list.length
                            var max = workspaceDots.maxSlots

                            if (total <= max) {
                                
                                visibleList = list
                            } else {
                                
                                var startIdx = 0

                                
                                if (focusedIdx >= max - 1) {
                                    startIdx = focusedIdx - (max - 2)
                                }

                                
                                if (startIdx + max > total) {
                                    startIdx = total - max
                                }
                                
                                if (startIdx < 0) startIdx = 0

                                
                                for (var i = startIdx; i < startIdx + max; i++) {
                                    visibleList.push(list[i])
                                }
                            }

                            workspaceDots.workspaces = visibleList
                        } catch (e) {}
                    }
                }
            }

            Timer {
                interval: 200
                running: true
                repeat: true
                onTriggered: listProc.running = true
            }

            Process {
                id: focusProc
                running: false
            }
        }
    }
}


// ---- Clock ----

PanelWindow {
    anchors.top: true
    anchors.right: true
    margins.top: 4
    margins.right: 150
    implicitWidth: 180
    implicitHeight: 30
    color: "transparent"
    
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: "#cc111111"

        Text {
            id: clock
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "#96d3f8"
            font.bold: true
            font.pointSize: 11
        }

        Process {
            id: dateProc
            command: ["date", "+%I:%M %p | %Y-%m-%d"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: clock.text = this.text.trim()
            }
        }

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: dateProc.running = true
        }
    }
}

// ---- NetWork ----

Item {
    id: networkWidget

    property bool isOpen: false
    property bool panelVisible: false

    property string connectionName: ""
    property string connectionType: ""
    property bool isConnected: false
    property string internetStatus: "full" 

    property var wifiNetworks: []
    
    property bool showPasswordUI: false
    property string selectedNetwork: ""
    property string passwordInput: ""
    property string errorMessage: ""

    
    Process {
        id: nmcliProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text.trim()
                if (text === "") {
                    networkWidget.isConnected = false
                    networkWidget.connectionName = "No Connection"
                    networkWidget.connectionType = ""
                    return
                }
                
                var lines = text.split("\n")
                var foundRealConnection = false
                
                for (var i = 0; i < lines.length; i++) {
                    
                    var lastColonIdx = lines[i].lastIndexOf(":")
                    if (lastColonIdx !== -1) {
                        var name = lines[i].substring(0, lastColonIdx)
                        var type = lines[i].substring(lastColonIdx + 1)
                        
                        if (type === "loopback") continue
                        
                        networkWidget.isConnected = true
                        networkWidget.connectionName = name
                        
                        if (type.includes("wireless")) networkWidget.connectionType = "wifi"
                        else if (type.includes("ethernet")) networkWidget.connectionType = "ethernet"
                        else networkWidget.connectionType = type
                        
                        foundRealConnection = true
                        break
                    }
                }
                if (!foundRealConnection) {
                    networkWidget.isConnected = false
                    networkWidget.connectionName = "No Connection"
                    networkWidget.connectionType = ""
                }
            }
        }
    }

    
    Process {
        id: connectivityProc
        command: ["nmcli", "networking", "connectivity"]
        stdout: StdioCollector {
            onStreamFinished: {
                var status = this.text.trim()
                if (status !== "") {
                    networkWidget.internetStatus = status
                }
            }
        }
    }

    
    Process {
        id: wifiScanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "auto"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text.trim()
                var networks = []
                if (text === "") {
                    networkWidget.wifiNetworks = []
                    return
                }
                
                var lines = text.split("\n")
                var seen = {}
                for (var i = 0; i < lines.length; i++) {
                    
                    var lastColon = lines[i].lastIndexOf(":")
                    if (lastColon !== -1) {
                        var security = lines[i].substring(lastColon + 1)
                        var rest = lines[i].substring(0, lastColon)
                        var secondLastColon = rest.lastIndexOf(":")
                        if (secondLastColon !== -1) {
                            var signal = parseInt(rest.substring(secondLastColon + 1)) || 0
                            var ssid = rest.substring(0, secondLastColon)
                            
                            if (!ssid || seen[ssid]) continue
                            seen[ssid] = true
                            
                            networks.push({
                                name: ssid,
                                strength: signal,
                                isSecure: security !== "" && security !== "--"
                            })
                        }
                    }
                }
                networks.sort(function(a, b) { return b.strength - a.strength })
                networkWidget.wifiNetworks = networks
            }
        }
    }

    
    Process {
        id: connectProc
        running: false
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.includes("Error")) {
                    networkWidget.errorMessage = "Authentication failed. Try again."
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                nmcliProc.running = true
                connectivityProc.running = true
                if (networkWidget.errorMessage === "") {
                    networkWidget.isOpen = false
                    networkFadeAnimation.start()
                    networkHideTimer.restart()
                }
            }
        }
    }

    
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            nmcliProc.running = true
            connectivityProc.running = true
        }
    }

    
    PanelWindow {
        id: networkPanel
        anchors.top: true
        anchors.right: true
        margins.top: 4
        margins.right: 96
        implicitWidth: 46
        implicitHeight: 30
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.centerIn: parent
            width: 30
            height: 30
            radius: 8
            color: networkBtnMouseArea.containsMouse ? "#96d3f8" : "#cc111111"
            Text {
                anchors.centerIn: parent
                font.family: "Symbols Nerd Font"
                font.pointSize: 14
                font.bold: false
                color: networkBtnMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
                text: {
                    if (!networkWidget.isConnected) return String.fromCodePoint(0xf0a8e) 
                    if (networkWidget.internetStatus === "limited") return String.fromCodePoint(0xf16b5) 
                    if (networkWidget.connectionType === "wifi") return String.fromCodePoint(0xF1EB) 
                    if (networkWidget.connectionType === "ethernet") return String.fromCodePoint(0xF0E8) 
                    return String.fromCodePoint(0xF0AC) 
                }
            }
            MouseArea {
                id: networkBtnMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (networkWidget.isOpen) {
                        networkWidget.isOpen = false
                        networkFadeAnimation.start()
                        networkHideTimer.restart()
                    } else {
                        networkWidget.isOpen = true
                        networkWidget.panelVisible = true
                        networkWidget.showPasswordUI = false
                        networkWidget.errorMessage = ""
                        networkCloseTimer.stop()
                        wifiScanProc.running = true
                    }
                }
            }
        }

        
        PopupWindow {
            id: networkPopup
            anchor.window: networkPanel
            anchor.rect.x: networkPanel.width - networkPopup.width
            anchor.rect.y: networkPanel.height + 4
            visible: networkWidget.panelVisible
            color: "transparent"
            width: 260
            
            height: {
                if (networkWidget.showPasswordUI) return 230
                var count = networkWidget.wifiNetworks.length
                if (count === 0) return 110
                return Math.min(350, 110 + (count * 30))
            }
            Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) networkCloseTimer.stop()
                    else networkCloseTimer.restart()
                }
            }

            Item {
                id: networkPopupContent
                anchors.fill: parent
                opacity: 0.0
                states: State {
                    name: "visible"
                    when: networkWidget.isOpen
                    PropertyChanges { target: networkPopupContent; opacity: 1.0 }
                }
                transitions: Transition {
                    NumberAnimation { property: "opacity"; duration: 500; easing.type: Easing.OutQuad }
                }
                NumberAnimation on opacity {
                    id: networkFadeAnimation
                    running: false
                    to: 0.0
                    duration: 500
                    easing.type: Easing.InOutQuad
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#cc111111"
                    radius: 12
                    border.color: "#333333"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        
                        Row {
                            spacing: 10
                            Text {
                                font.family: "Symbols Nerd Font"
                                font.pointSize: 18
                                color: "#96d3f8"
                                text: {
                                    if (!networkWidget.isConnected) return String.fromCodePoint(0xf0a8e)
                                    if (networkWidget.internetStatus === "limited") return String.fromCodePoint(0xf16b5)
                                    if (networkWidget.connectionType === "wifi") return String.fromCodePoint(0xF1EB)
                                    if (networkWidget.connectionType === "ethernet") return String.fromCodePoint(0xF0E8)
                                    return String.fromCodePoint(0xF0AC)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                    text: networkWidget.connectionName || "No Connection"
                                }
                                Text {
                                    font.pixelSize: 11
                                    color: networkWidget.internetStatus === "limited" ? "#f38ba8" : "#96d3f8"
                                    text: {
                                        if (!networkWidget.isConnected) return "Disconnected"
                                        if (networkWidget.internetStatus === "limited") return "No Internet Access"
                                        if (networkWidget.internetStatus === "portal") return "Login Required"
                                        return "Connected"
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: "#333333" }

                        
                        Column {
                            visible: networkWidget.showPasswordUI
                            width: parent.width
                            spacing: 12
                            
                            Text {
                                text: "Connect to: " + networkWidget.selectedNetwork
                                font.pixelSize: 12
                                font.bold: true
                                color: "#96d3f8"
                            }

                            Rectangle {
                                width: parent.width
                                height: 36
                                radius: 8
                                color: "#1a1b26"
                                border.color: passwordField.activeFocus ? "#96d3f8" : "transparent"
                                border.width: 1

                                TextInput {
                                    id: passwordField
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    echoMode: TextInput.Password
                                    focus: networkWidget.showPasswordUI
                                    
                                    onTextChanged: networkWidget.passwordInput = text
                                    onAccepted: {
                                        if (text !== "") {
                                            networkWidget.errorMessage = ""
                                            connectProc.command = ["nmcli", "device", "wifi", "connect", networkWidget.selectedNetwork, "password", text]
                                            connectProc.running = true
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: networkWidget.errorMessage !== ""
                                text: networkWidget.errorMessage
                                color: "#f38ba8"
                                font.pixelSize: 11
                            }

                            Row {
                                spacing: 8
                                width: parent.width
                                
                                Rectangle {
                                    width: (parent.width - 8) / 2
                                    height: 30
                                    radius: 6
                                    color: cancelBtnArea.containsMouse ? "#555555" : "transparent"
                                    border.color: "#555555"
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#ffffff"; font.pixelSize: 11 }
                                    MouseArea {
                                        id: cancelBtnArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: networkWidget.showPasswordUI = false
                                    }
                                }

                                Rectangle {
                                    width: (parent.width - 8) / 2
                                    height: 30
                                    radius: 6
                                    color: connectBtnArea.containsMouse ? "#96d3f8" : "#96d3f8"
                                    Text { anchors.centerIn: parent; text: "Connect"; color: "#cc111111"; font.pixelSize: 11; font.bold: true }
                                    MouseArea {
                                        id: connectBtnArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (passwordField.text !== "") {
                                                networkWidget.errorMessage = ""
                                                connectProc.command = ["nmcli", "device", "wifi", "connect", networkWidget.selectedNetwork, "password", passwordField.text]
                                                connectProc.running = true
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        
                        Column {
                            visible: !networkWidget.showPasswordUI
                            width: parent.width
                            spacing: 4

                            Text {
                                text: networkWidget.wifiNetworks.length === 0 ? "No Wi-Fi Networks Found" : "Available Networks"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#96d3f8"
                            }

                            ListView {
                                width: parent.width
                                height: parent.height - 20
                                model: networkWidget.wifiNetworks
                                clip: true
                                spacing: 2

                                delegate: Rectangle {
                                    required property var modelData
                                    width: ListView.view.width
                                    height: 30
                                    radius: 6
                                    color: wifiItemMouseArea.containsMouse ? "#96d3f8" : "transparent"

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 8

                                        Text {
                                            font.family: "Symbols Nerd Font"
                                            font.pixelSize: 12
                                            color: wifiItemMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
                                            text: String.fromCodePoint(0xF1EB)
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 12
                                            color: wifiItemMouseArea.containsMouse ? "#cc111111" : "#ffffff"
                                            anchors.verticalCenter: parent.verticalCenter
                                            elide: Text.ElideRight
                                            width: parent.width - 60
                                        }
                                        Text {
                                            text: modelData.strength + "%"
                                            font.pixelSize: 10
                                            color: wifiItemMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: wifiItemMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.isSecure) {
                                                networkWidget.selectedNetwork = modelData.name
                                                networkWidget.showPasswordUI = true
                                                networkWidget.errorMessage = ""
                                                passwordField.text = ""
                                                passwordField.forceActiveFocus()
                                            } else {
                                                connectProc.command = ["nmcli", "device", "wifi", "connect", modelData.name]
                                                connectProc.running = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    Timer {
        id: networkCloseTimer
        interval: 2000
        running: false; repeat: false
        onTriggered: {
            networkWidget.isOpen = false
            networkFadeAnimation.start()
            networkHideTimer.restart()
        }
    }

    Timer {
        id: networkHideTimer
        interval: 500
        running: false; repeat: false
        onTriggered: {
            if (!networkWidget.isOpen) {
                networkWidget.panelVisible = false
            }
        }
    }
}

// ---- volume control ----

Item {
    id: volumeWidget

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
    }

    
    readonly property var audio: Pipewire.defaultAudioSink?.audio ?? null
    readonly property bool muted: audio?.muted ?? false
    readonly property int volume: audio ? Math.round(audio.volume * 100) : 0

   
    readonly property var micAudio: Pipewire.defaultAudioSource?.audio ?? null
    readonly property bool micMuted: micAudio?.muted ?? false
    readonly property int micVolume: micAudio ? Math.round(micAudio.volume * 100) : 0

    
    property bool isOpen: false
    property bool panelVisible: false

    
    PanelWindow {
        id: volumePanel
        anchors.top: true
        anchors.right: true
        margins.top: 4
        margins.right: 50
        implicitWidth: 46
        implicitHeight: 30
        color: "transparent"
        
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.centerIn: parent
            width: 30
            height: 30
            radius: 8
            color: volumeButtonMouseArea.containsMouse ? "#96d3f8" : "#cc111111"

            Text {
                anchors.centerIn: parent
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                font.bold: true
                color: volumeButtonMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
                
                text: {
                    if (volumeWidget.muted || volumeWidget.volume === 0) return String.fromCodePoint(0xF026)
                    if (volumeWidget.volume < 50) return String.fromCodePoint(0xF027)
                    return String.fromCodePoint(0xF028)
                }
            }

            MouseArea {
                id: volumeButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    if (volumeWidget.isOpen) {
                        
                        volumeWidget.isOpen = false
                        volumeFadeAnimation.start()
                        volumeHideTimer.restart()
                    } else {
                        
                        volumeWidget.isOpen = true
                        volumeWidget.panelVisible = true
                        volumeCloseTimer.stop()
                    }
                }
                
                onEntered: {
                    volumeCloseTimer.stop()
                    volumeGraceTimer.stop()
                }
                
                onExited: {
                    if (volumeWidget.isOpen) {
                        volumeGraceTimer.restart()
                    }
                }
                
                onWheel: (wheel) => {
                    if (!volumeWidget.audio) return
                    let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                    volumeWidget.audio.volume = Math.max(0, Math.min(1, volumeWidget.audio.volume + step))
                }
            }
        }

        
        PopupWindow {
            id: popup
            anchor.window: volumePanel
            anchor.rect.x: volumePanel.width - popup.width
            anchor.rect.y: volumePanel.height + 4
            
            visible: volumeWidget.panelVisible 
            color: "transparent"
            width: 240
            height: 130 

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        
                        volumeGraceTimer.stop()
                        volumeCloseTimer.stop()
                    } else {
                        if (volumeWidget.isOpen && !volumeButtonMouseArea.containsMouse) {
                            volumeCloseTimer.restart()
                        }
                    }
                }
            }

            Item {
                id: popupContent
                anchors.fill: parent
                
                opacity: 0.0
                
                states: State {
                    name: "visible"
                    when: volumeWidget.isOpen
                    PropertyChanges { target: popupContent; opacity: 1.0 }
                }
                
                transitions: Transition {
                    NumberAnimation { property: "opacity"; duration: 500; easing.type: Easing.OutQuad }
                }

                NumberAnimation on opacity {
                    id: volumeFadeAnimation
                    running: false
                    to: 0.0
                    duration: 500 
                    easing.type: Easing.InOutQuad
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#cc111111"
                    radius: 12
                    border.color: "#333333"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 16 
                        width: parent.width - 40

                        
                        Column {
                            spacing: 8
                            width: parent.width

                            Row {
                                spacing: 10
                                width: parent.width
                                Text {
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: "#96d3f8"
                                    text: volumeWidget.muted ? String.fromCodePoint(0xF026) : (volumeWidget.volume < 50 ? String.fromCodePoint(0xF027) : String.fromCodePoint(0xF028))
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#ffffff"
                                    text: volumeWidget.muted ? "Muted" : volumeWidget.volume + "%"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Item {
                                width: parent.width
                                height: 20 
                                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 6; radius: 3; color: "#333333" }
                                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width * (volumeWidget.muted ? 0 : volumeWidget.volume / 100); height: 6; radius: 3; color: "#96d3f8" }
                                Rectangle {
                                    id: knob
                                    x: (parent.width - 14) * (volumeWidget.muted ? 0 : volumeWidget.volume / 100)
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 14; height: 14; radius: 7
                                    color: "#ffffff"; border.color: "#00000044"; border.width: 1
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        drag.target: knob
                                        drag.axis: Drag.XAxis
                                        drag.minimumX: 0
                                        drag.maximumX: parent.parent.width - knob.width
                                        onPositionChanged: {
                                            if (drag.active && volumeWidget.audio) {
                                                let pct = knob.x / (parent.parent.width - knob.width)
                                                volumeWidget.audio.volume = Math.max(0, Math.min(1, pct))
                                                volumeWidget.audio.muted = false 
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        
                        Column {
                            spacing: 8
                            width: parent.width

                            Row {
                                spacing: 10
                                width: parent.width
                                Text {
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: "#96d3f8"
                                    text: volumeWidget.micMuted ? String.fromCodePoint(0xF131) : String.fromCodePoint(0xF130)
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#ffffff"
                                    text: volumeWidget.micMuted ? "Muted" : volumeWidget.micVolume + "%"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Item {
                                width: parent.width
                                height: 20 

                                Rectangle { 
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 6
                                    radius: 3
                                    color: "#333333" 
                                }
                                
                                Rectangle { 
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * (volumeWidget.micMuted ? 0 : volumeWidget.micVolume / 100)
                                    height: 6
                                    radius: 3
                                    color: "#96d3f8" 
                                }
                                
                                Rectangle {
                                    id: micKnob
                                    x: (parent.width - 14) * (volumeWidget.micMuted ? 0 : volumeWidget.micVolume / 100)
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 14; height: 14; radius: 7
                                    color: "#ffffff"
                                    border.color: "#00000044"
                                    border.width: 1
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        drag.target: micKnob
                                        drag.axis: Drag.XAxis
                                        drag.minimumX: 0
                                        drag.maximumX: parent.parent.width - micKnob.width
                                        onPositionChanged: {
                                            if (drag.active && volumeWidget.micAudio) {
                                                let pct = micKnob.x / (parent.parent.width - micKnob.width)
                                                volumeWidget.micAudio.volume = Math.max(0, Math.min(1, pct))
                                                volumeWidget.micAudio.muted = false 
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    Timer {
        id: volumeGraceTimer
        interval: 100
        running: false; repeat: false
        onTriggered: volumeCloseTimer.restart()
    }

    
    Timer {
        id: volumeCloseTimer
        interval: 1000
        running: false; repeat: false
        onRunningChanged: {
            if (running) { 
                volumeFadeDelayTimer.restart() 
            }
        }
        onTriggered: {
            volumeWidget.isOpen = false
            volumeFadeAnimation.start()
            volumeHideTimer.restart()
        }
    }

    
    Timer {
        id: volumeFadeDelayTimer
        interval: 500
        running: false; repeat: false
        onTriggered: volumeFadeAnimation.start()
    }

    
    Timer {
        id: volumeHideTimer
        interval: 500
        running: false; repeat: false
        onTriggered: {
            if (!volumeWidget.isOpen) {
                volumeWidget.panelVisible = false
            }
        }
    }
}

 // ---- shut down ----

 Item {
    id: powerWidget
    
    property bool isOpen: false
    property bool panelVisible: false

    
    PanelWindow {
        id: powerPanel
        anchors.top: true
        anchors.right: true
        margins.top: 4
        margins.right: 4 
        implicitWidth: 46
        implicitHeight: 30
        color: "transparent"
        
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.centerIn: parent
            width: 30
            height: 30
            radius: 8
            color: powerBtnMouseArea.containsMouse ? "#96d3f8" : "#cc111111"

            Text {
                anchors.centerIn: parent
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                font.bold: true
                color: powerBtnMouseArea.containsMouse ? "#cc111111" : "#96d3f8"
                text: String.fromCodePoint(0xF011)
            }

            MouseArea {
                id: powerBtnMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    if (powerWidget.isOpen) {
                        powerWidget.isOpen = false
                        powerFadeAnimation.start()
                        powerHideTimer.restart()
                    } else {
                        powerWidget.isOpen = true
                        powerWidget.panelVisible = true
                        powerCloseTimer.stop()
                    }
                }
                
                onEntered: {
                    powerCloseTimer.stop()
                    powerGraceTimer.stop()
                }
                
                onExited: {
                    if (powerWidget.isOpen) {
                        
                        powerGraceTimer.restart()
                    }
                }
            }
        }

        
        PopupWindow {
            id: powerPopup
            anchor.window: powerPanel
            anchor.rect.x: powerPanel.width - powerPopup.width
            anchor.rect.y: powerPanel.height + 4
            
            visible: powerWidget.panelVisible 
            color: "transparent"
            width: 180
            height: 200

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        
                        powerGraceTimer.stop()
                        powerCloseTimer.stop()
                    } else {
                        if (powerWidget.isOpen && !powerBtnMouseArea.containsMouse) {
                            powerCloseTimer.restart()
                        }
                    }
                }
            }

            Item {
                id: powerPopupContent
                anchors.fill: parent
                
                opacity: 0.0 
                
                states: State {
                    name: "visible"
                    when: powerWidget.isOpen
                    PropertyChanges { target: powerPopupContent; opacity: 1.0 }
                }
                
                transitions: Transition {
                    NumberAnimation { property: "opacity"; duration: 500; easing.type: Easing.OutQuad }
                }

                NumberAnimation on opacity {
                    id: powerFadeAnimation
                    running: false
                    to: 0.0
                    duration: 500 
                    easing.type: Easing.InOutQuad
                }

                Column {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    component PowerButton: Rectangle {
                        id: btn
                        anchors.right: parent.right
                        
                        width: btnMouseArea.containsMouse ? 160 : 50
                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        
                        height: 40
                        radius: 12 
                        color: btnMouseArea.containsMouse ? (btn.isDanger ? "#f38ba8" : "#96d3f8") : "#cc111111"
                        border.color: btnMouseArea.containsMouse ? "transparent" : "#333333"
                        border.width: 1
                        clip: true

                        property string icon: ""
                        property string label: ""
                        property bool isDanger: false
                        signal clicked()

                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12
                            layoutDirection: Qt.RightToLeft 

                            Text {
                                text: btn.icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                font.bold: true
                                color: btnMouseArea.containsMouse ? "#cc111111" : (btn.isDanger ? "#f38ba8" : "#96d3f8")
                            }
                            
                            Text {
                                text: btn.label
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 12
                                font.bold: true
                                color: btnMouseArea.containsMouse ? "#cc111111" : (btn.isDanger ? "#f38ba8" : "#96d3f8")
                                opacity: btnMouseArea.containsMouse ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                            }
                        }

                        MouseArea {
                            id: btnMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btn.clicked()
                        }
                    }

                    PowerButton {
                        icon: String.fromCodePoint(0xF08B)
                        label: "Log Out"
                        onClicked: Quickshell.execDetached(["niri", "msg", "action", "quit", "--skip-confirmation"])
                    }

                    PowerButton {
                        icon: String.fromCodePoint(0xF186)
                        label: "Suspend"
                        onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                    }

                    PowerButton {
                        icon: String.fromCodePoint(0xF021)
                        label: "Restart"
                        onClicked: Quickshell.execDetached(["systemctl", "reboot"])
                    }

                    PowerButton {
                        icon: String.fromCodePoint(0xF011)
                        label: "Shut Down"
                        isDanger: true
                        onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
                    }
                }
            }
        }
    }

    
    Timer {
        id: powerGraceTimer
        interval: 100
        running: false; repeat: false
        onTriggered: powerCloseTimer.restart()
    }

    
    Timer {
        id: powerCloseTimer
        interval: 1000
        running: false; repeat: false
        onRunningChanged: {
            if (running) { 
                powerFadeDelayTimer.restart() 
            }
        }
        onTriggered: {
            powerWidget.isOpen = false
            powerFadeAnimation.start()
            powerHideTimer.restart()
        }
    }

    
    Timer {
        id: powerFadeDelayTimer
        interval: 500
        running: false; repeat: false
        onTriggered: powerFadeAnimation.start()
    }

    
    Timer {
        id: powerHideTimer
        interval: 500
        running: false; repeat: false
        onTriggered: {
            if (!powerWidget.isOpen) {
                powerWidget.panelVisible = false
            }
        }
    }
}

// ----taskbar----

Item {
    id: taskbarWidget
    
    property bool isOpen: false
    property bool isHovered: false
    property var openWindows: []
    property int focusedWindowId: -1

    Process {
        id: fetchProc
        command: ["niri", "msg", "--json", "windows"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var list = JSON.parse(this.text)
                    list.sort(function(a, b) { return a.id - b.id })
                    
                    var focusId = -1
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].is_focused) {
                            focusId = list[i].id
                            break
                        }
                    }
                    
                    if (list.length !== taskbarWidget.openWindows.length || focusId !== taskbarWidget.focusedWindowId) {
                        taskbarWidget.focusedWindowId = focusId
                        taskbarWidget.openWindows = list
                    } else {
                        var changed = false
                        for (var j = 0; j < list.length; j++) {
                            if (list[j].id !== taskbarWidget.openWindows[j].id) {
                                changed = true
                                break
                            }
                        }
                        if (changed) {
                            taskbarWidget.focusedWindowId = focusId
                            taskbarWidget.openWindows = list
                        }
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: fetchProc.running = true
    }

    function getGroupedWindows() {
        var groups = {}
        for (var i = 0; i < openWindows.length; i++) {
            var win = openWindows[i]
            var appId = win.app_id
            if (!groups[appId]) {
                groups[appId] = { app_id: appId, windows: [] }
            }
            groups[appId].windows.push(win)
        }
        var result = []
        for (var key in groups) {
            result.push(groups[key])
        }
        return result
    }

    
    PanelWindow {
        id: hoverTrigger
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 15 
        color: "transparent"
        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            width: 400 
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            hoverEnabled: true
            onEntered: {
                taskbarWidget.isHovered = true
                taskbarWidget.isOpen = true
            }
            onExited: {
                taskbarWidget.isHovered = false
            }
        }
    }

    
    PanelWindow {
        id: taskbarWindow
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 45
        color: "transparent"
        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            id: dockContent
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(100, appRow.implicitWidth + 24)
            height: 43
            radius: 16
            color: "#cc111111" 
            border.color: "#333333"
            border.width: 1

            y: taskbarWidget.isOpen ? 0 : 80 
            Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            HoverHandler {
                onHoveredChanged: {
                    taskbarWidget.isHovered = hovered
                }
            }

            Row {
                id: appRow
                anchors.centerIn: parent
                spacing: 12
                
                Repeater {
                    model: taskbarWidget.getGroupedWindows()
                    
                    Rectangle {
                        required property var modelData
                        width: 36
                        height: 36
                        radius: 8
                        
                        property bool hasFocus: {
                            for (var i = 0; i < modelData.windows.length; i++) {
                                if (modelData.windows[i].id === taskbarWidget.focusedWindowId) return true
                            }
                            return false
                        }
                        
                        color: hasFocus ? "#88000000" : (appMouseArea.containsMouse ? "#96d3f8" : "transparent")
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        property var desktopEntry: DesktopEntries.byId(modelData.app_id)
                        property string iconName: desktopEntry ? desktopEntry.icon : ""

                        IconImage {
                            anchors.centerIn: parent
                            source: Quickshell.iconPath(parent.iconName)
                            implicitSize: 25
                            visible: parent.iconName !== ""
                            
                            Text {
                                anchors.centerIn: parent
                                visible: parent.status !== Image.Ready
                                text: modelData.app_id.substring(0, 2).toUpperCase()
                                color: appMouseArea.containsMouse ? "#e3121217" : "#96d3f8"
                                font.pointSize: 8
                                font.bold: true
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            visible: parent.iconName === ""
                            text: modelData.app_id.substring(0, 2).toUpperCase()
                            color: appMouseArea.containsMouse ? "#e3121217" : "#96d3f8"
                            font.pointSize: 8
                            font.bold: true
                        }
                        
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.margins: 2
                            visible: modelData.windows.length > 1
                            text: modelData.windows.length
                            color: appMouseArea.containsMouse ? "#e3121217" : "#96d3f8"
                            font.pointSize: 8
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: appMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var wins = modelData.windows
                                var targetId = wins[0].id 

                                for (var i = 0; i < wins.length; i++) {
                                    if (wins[i].id === taskbarWidget.focusedWindowId) {
                                        var nextIndex = (i + 1) % wins.length 
                                        targetId = wins[nextIndex].id
                                        break
                                    }
                                }

                                Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(targetId)])
                            }
                        }
                    }
                }
            }
        }
    }

    
    Timer {
        interval: 250
        running: taskbarWidget.isOpen
        repeat: true
        onTriggered: {
            if (!taskbarWidget.isHovered) {
                taskbarWidget.isOpen = false
            }
        }
    }
}





    
}