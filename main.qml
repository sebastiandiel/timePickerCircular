import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    visible: true
    width: 300
    height: 450
    title: qsTr("TimePickerCircular")
    TimePickerCircular {
        initialMinute: 35
        initialHour: 8
        onTimeChanged: {
            console.debug(hour+":"+minute)
        }
        onOkClicked: {
            console.debug(hour+":"+minute+" confirmed")
            close();
        }
        onCancelled: {
            console.debug("cancelled")
            close()
        }
    }
}
