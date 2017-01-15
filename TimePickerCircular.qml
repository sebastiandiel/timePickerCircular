import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

Item {
    id: timePickerBase
    property color circleColor: "gray"
    property color dotColor: "red"
    property color textColor: "black"
    property color backgroundColor: "white"
    property int initialHour: 10
    property int initialMinute: 25
    property int selectedHour: initialHour
    property int selectedMinute: initialMinute
    property bool pm: initialHour >= 12

    signal hourChanged(var hour)
    signal minuteChanged(var minute)
    signal timeChanged(var hour, var minute)
    signal okClicked(var hour, var minute)
    signal cancelled()
    property real buttonSize: 50

    anchors.fill: parent
    states: [
        State {
            name: "vertical"
            AnchorChanges {
                target: buttonRect
                anchors.bottom: timePickerBase.bottom
                anchors.left: timePickerBase.left
                anchors.right: timePickerBase.right
                anchors.top: undefined
            }
            PropertyChanges {
                target: buttonRect
                height: buttonSize
                width: undefined
                visible: true
            }
            AnchorChanges {
                target: displayRect
                anchors.top: timePickerBase.top
                anchors.left: timePickerBase.left
                anchors.right: timePickerBase.right
                anchors.bottom: undefined
            }
            PropertyChanges {
                target: displayRect
                height: Math.max(buttonSize, timePickerBase.height-timePickerBase.width-buttonRect.height)
                width: undefined
            }
            AnchorChanges {
                target: timePickerBox
                anchors.top: displayRect.bottom
                anchors.bottom: buttonRect.top
                anchors.left: undefined
                anchors.right: undefined
                anchors.horizontalCenter: timePickerBase.horizontalCenter
                anchors.verticalCenter: undefined
            }
            PropertyChanges {
                target: timePickerBox
                width: height
                height: undefined
            }
        },
        State {
            name: "horizontal"
            AnchorChanges {
                target: buttonRect
                anchors.right: timePickerBase.right
                anchors.top: timePickerBase.top
                anchors.bottom: timePickerBase.bottom
                anchors.left: undefined
            }
            PropertyChanges {
                target: buttonRect
                width: 2.2 * buttonSize
                height: undefined
                visible: true
            }
            AnchorChanges {
                target: displayRect
                anchors.left: timePickerBase.left
                anchors.top: timePickerBase.top
                anchors.bottom: timePickerBase.bottom
                anchors.right: undefined
            }
            PropertyChanges {
                target: displayRect
                height: undefined
                width: Math.max(buttonSize, timePickerBase.width-timePickerBase.height-buttonRect.width)
            }
            AnchorChanges {
                target: timePickerBox
                anchors.left: displayRect.right
                anchors.right: buttonRect.left
                anchors.verticalCenter: timePickerBase.verticalCenter
            }
            PropertyChanges {
                target: timePickerBox
                height: width
            }
        }
    ]

    state: timePickerBase.width < timePickerBase.height ? "vertical" : "horizontal"
    MouseArea {
        anchors.fill: parent // to prevent mouse event to slip through
    }
    Component.onCompleted: {
        textInput.forceActiveFocus()
    }
    onVisibleChanged: {
        if (visible) {
            textInput.forceActiveFocus()
            var dummy
            textInput.onFocusChanged(dummy) //nessecary, perhaps because it may STILL have had the Focus
        }
    }

    Rectangle {
        id: displayRect
        function timeString(){
            var mPre = timePickerBase.selectedMinute < 10 ? "0" : ""
            var hPre = timePickerBase.selectedHour < 10 ? "0" : ""
            return hPre + timePickerBase.selectedHour + ":" + mPre + timePickerBase.selectedMinute
        }
        color: timePickerBase.backgroundColor
        visible: true
        TextInput {
            id: textInput
            anchors.centerIn: parent
            inputMask: "00:00"
            text: displayRect.timeString()
            font.pointSize: Math.max(1, Math.min(displayRect.height / 1.3, displayRect.width / 3.9))
            validator: RegExpValidator { regExp: /^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d))$/ }
            cursorVisible: true
            inputMethodHints: Qt.ImhTime
            onAccepted: {
                timePickerBase.okClicked(timePickerBase.selectedHour, timePickerBase.selectedMinute)
            }
            onFocusChanged: {
                cursorPosition = 0
                cursorVisible = focus
            }
            onActiveFocusChanged: {
                var dummy
                onFocusChanged(dummy)
            }

            onEditingFinished: {
                timeChanged(timePickerBase.selectedHour, timePickerBase.selectedMinute)
            }
            onTextChanged: {
                timePickerBase.selectedHour=textInput.text.substring(0,2).valueOf()
                timePickerBase.selectedMinute=textInput.text.substring(3,5).valueOf()
                timePickerBase.pm = timePickerBase.selectedHour >=12
            }
            Keys.onPressed: {
                if (event.key === 50 && cursorPosition === 0 && text.substring(1,1) < 2) {
                    if (text.substring(2,1) > 3) {
                        text = 2+"0"+text.substring(2,5)
                        cursorPosition = 0
                    }
                }
                if (event.key === Qt.Key_Escape) {
                    event.accepted = true
                    okButton.onClicked()
                } else {
                    event.accepted = false
                }
            }
        }
    }
    Rectangle {
        id: buttonRect
        anchors.bottom: timePickerBase.bottom
        anchors.left: timePickerBase.left
        anchors.right: timePickerBase.right
        height: buttonSize
        width : buttonSize * 4
        color: timePickerBase.backgroundColor
        visible: true

        GridLayout {
            anchors.margins: 0
            property real minButtonWidth: buttonRect.width / 4.4
            columnSpacing: 3
            anchors.fill: parent
            flow: timePickerBase.state === "vertical" ? GridLayout.LeftToRight : GridLayout.TopToBottom
            Button {
                id: amButton
                enabled: timePickerBase.pm ? true : false
                Layout.maximumWidth: timePickerBase.state === "vertical" ? buttonRect.width / 4.4 : buttonRect.width
                Layout.maximumHeight: timePickerBase.state === "vertical" ? buttonRect.height : buttonRect.height / 4.4
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: "AM"
                onClicked: {
                    timePickerBase.selectedHour -= 12
                    timePickerBase.pm = false
                    timePickerBase.hourChanged(timePickerBase.selectedHour)
                    timePickerBase.timeChanged(timePickerBase.selectedHour, timePickerBase.selectedMinute)
                }
            }
            Button {
                id: pmButton
                enabled: timePickerBase.pm ? false : true
                Layout.maximumWidth: timePickerBase.state === "vertical" ? buttonRect.width / 4.4 : buttonRect.width
                Layout.maximumHeight: timePickerBase.state === "vertical" ? buttonRect.height : buttonRect.height / 4.4
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: "PM"
                onClicked: {
                    timePickerBase.selectedHour += 12
                    timePickerBase.pm = true
                    timePickerBase.hourChanged(timePickerBase.selectedHour)
                    timePickerBase.timeChanged(timePickerBase.selectedHour, timePickerBase.selectedMinute)
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: true
                color: timePickerBase.backgroundColor
            }
            Button {
                id: cancelButton
                Layout.maximumWidth: timePickerBase.state === "vertical" ? buttonRect.width / 4.4 : buttonRect.width
                Layout.maximumHeight: timePickerBase.state === "vertical" ? buttonRect.height : buttonRect.height / 4.4
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: "Cancel"
                onClicked: {
                    timePickerBase.cancelled()
                    timePickerCircle.state = "hours"
                }
            }
            Button {
                id: okButton
                Layout.maximumWidth: timePickerBase.state === "vertical" ? buttonRect.width / 4.4 : buttonRect.width
                Layout.maximumHeight: timePickerBase.state === "vertical" ? buttonRect.height : buttonRect.height / 4.4
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: "OK"
                onClicked: {
                    timePickerBase.okClicked(timePickerBase.selectedHour, timePickerBase.selectedMinute)
                    timePickerCircle.state = "hours"
                }
            }
        }
    }
    Rectangle {
        visible: true
        id: timePickerBox
        x: 60
        y: 160
        width: 100
        height: 100
        color: timePickerBase.backgroundColor
        QtObject {
            id: priv
            property real outerSize: Math.min(timePickerBox.width, timePickerBox.height)
            property real dotSize: outerSize / 9
            property real centerX: outerSize / 2
            property real centerY: outerSize / 2
            property real outerRadius: (outerSize - dotSize * 1.3) / 2
            property real minRadius: outerRadius - dotSize * 2
            property real maxRadius: 2 * dotSize + outerSize / 2
            property point initialPos: timePickerCircle.getPosFromTime(timePickerBase.initialHour, timePickerBase.initialMinute)
        }
        Rectangle {
            id: timePickerCircle
            state: "hours"
            states: [
                State {
                    name: "hours"
                },
                State {
                    name: "minutes"
                }
            ]
            onVisibleChanged: state = "hours"
            onStateChanged: {
                outerMouseArea.targetX = Qt.binding(function() { return priv.initialPos.x + priv.dotSize/2 })
                outerMouseArea.targetY = Qt.binding(function() { return priv.initialPos.y + priv.dotSize/2 })
            }
            function getAngleFromPosition(x,y) {
                x = x - priv.centerX
                y = - (y - priv.centerY)
                var angle = Math.atan2(x, y)
                return angle < 0 ? angle + 2 * Math.PI : angle
            }
            function getDotPosFromAngle(alpha) {
                return Qt.point(priv.centerX + priv.outerRadius * Math.sin(alpha) - priv.dotSize / 2, priv.centerY - priv.outerRadius * Math.cos(alpha) - priv.dotSize / 2)
            }
            function allowedInputPosition(x,y) {
                var r = Math.sqrt(Math.pow(priv.centerX - x,2) + Math.pow(priv.centerY - y, 2));
                return (r < priv.maxRadius && r > priv.minRadius)
            }
            function getHourFromAngle(alpha) {
                var hour = Math.round(12 * alpha / (2 * Math.PI))
                if (timePickerBase.pm) {
                    return hour + 12
                } else {
                    return hour
                }
            }
            function getAngleFromHour(hour) {
                return (hour % 12) * 2 * Math.PI / 12
            }
            function getMinuteFromAngle(alpha) {
                return Math.round(60 * alpha / (2 * Math.PI))
            }
            function getAngleFromMinute(minute) {
                return (minute % 60) * 2 * Math.PI / 60
            }
            function getRasterizedDotPos(x,y) {
                return getDotPosFromAngle(getAngleFromHour(getHourFromAngle(getAngleFromPosition(x, y))))
            }
            function getPosFromTime(hours, minutes) {
                if (timePickerCircle.state === "hours") {
                    return timePickerCircle.getDotPosFromAngle(timePickerCircle.getAngleFromHour(hours))
                } else {
                    return timePickerCircle.getDotPosFromAngle(timePickerCircle.getAngleFromMinute(minutes))
                }
            }
            function setClock(hours,minutes) {
                var pos = getPosFromTime(hours, minutes)
                outerMouseArea.targetX = pos.x + priv.dotSize/2
                outerMouseArea.targetY = pos.y + priv.dotSize/2
            }

            color: timePickerBase.circleColor
            visible: true
            radius: priv.outerSize/2
            height: priv.outerSize
            width: priv.outerSize

            Rectangle {
                id: handleCircle
                color: timePickerBase.dotColor
                visible: true
                width: priv.dotSize
                height: priv.dotSize
                radius: priv.dotSize / 2
                property point pos: timePickerCircle.getDotPosFromAngle(timePickerCircle.getAngleFromPosition(outerMouseArea.targetX, outerMouseArea.targetY))
                property bool exact: true
                x: handleCircle.pos.x
                y: handleCircle.pos.y
            }
            MouseArea {
                id: outerMouseArea
                anchors.fill: parent
                property real targetX: priv.initialPos.x + priv.dotSize/2
                property real targetY: priv.initialPos.y + priv.dotSize/2

                onPressAndHold: {
                    if (timePickerCircle.allowedInputPosition(mouse.x, mouse.y) && timePickerCircle.state === "minutes") {
                        handleCircle.exact = false
                    }
                }
                onPositionChanged: {
                    if (timePickerCircle.allowedInputPosition(mouse.x, mouse.y) && !handleCircle.exact) {
                        targetX = mouse.x
                        targetY = mouse.y

                        if (timePickerCircle.state === "hours") {
                            timePickerBase.selectedHour = timePickerCircle.getHourFromAngle(timePickerCircle.getAngleFromPosition(targetX, targetY))
                        } else {
                            timePickerBase.selectedMinute = timePickerCircle.getMinuteFromAngle(timePickerCircle.getAngleFromPosition(targetX, targetY))
                        }

                    }
                }
                onPressed: {
                    if (timePickerCircle.allowedInputPosition(mouse.x, mouse.y)) {
                        var position = timePickerCircle.getRasterizedDotPos(mouse.x, mouse.y)
                        targetX = position.x + priv.dotSize/2
                        targetY = position.y + priv.dotSize/2
                    }
                }
                onReleased: {
                    handleCircle.exact = true
                    if (timePickerCircle.state === "hours") {
                        timePickerBase.selectedHour = timePickerCircle.getHourFromAngle(timePickerCircle.getAngleFromPosition(targetX, targetY))
                        timePickerBase.hourChanged(timePickerBase.selectedHour)
                        timePickerCircle.state = "minutes"
                    } else {
                        timePickerBase.selectedMinute = timePickerCircle.getMinuteFromAngle(timePickerCircle.getAngleFromPosition(targetX, targetY))
                        timePickerBase.minuteChanged(timePickerBase.selectedMinute)
                        timePickerBase.timeChanged(timePickerBase.selectedHour, timePickerBase.selectedMinute)
                    }
                }
            }
            Repeater {
                id: timePickerRepeater
                property string activatedDot: ""
                property var hoursAmModel: ["0","1","2","3","4","5","6","7","8","9","10","11"]
                property var hoursPmModel: ["12","13","14","15","16","17","18","19","20","21","22","23"]
                property var minutesModel: ["0","05","10","15","20","25","30","35","40","45","50","55"]
                model: timePickerCircle.state === "hours" ? timePickerBase.pm ? hoursPmModel : hoursAmModel : minutesModel

                delegate: Rectangle {
                    id: timePickerDelegate
                    property real twoPi: 2 * Math.PI
                    property real alpha: index * twoPi / 12
                    property real r: priv.outerRadius
                    property point pos: timePickerCircle.getDotPosFromAngle(alpha)
                    x: timePickerDelegate.pos.x
                    y: timePickerDelegate.pos.y
                    width: priv.dotSize
                    height: priv.dotSize
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        color: timePickerBase.textColor
                        text: modelData
                    }
                }
            }
        }
    }
}
