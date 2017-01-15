import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    visible: true
    width: 840
    height: 480
    title: qsTr("Hello World")
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
