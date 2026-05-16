pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property string time: {
        const datePart = Qt.formatDateTime(clock.date, " MMM d yyyy | ");
        const timePart = Config.settings.militaryTimeClockFormat
            ? Qt.formatDateTime(clock.date, "HH:mm")
            : Qt.formatDateTime(clock.date, "hh:mm AP");
        return datePart + timePart;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
