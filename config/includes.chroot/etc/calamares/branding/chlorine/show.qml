import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation
    Timer {
        interval: 20000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }
    Slide {
        Image {
            id: background1
            source: "/usr/share/chlorine-branding/background.svg"
            width: 800; height: 450
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background1.bottom
            anchors.topMargin: 20
            text: "Welcome to Chlorine Linux"
            color: "#4DD0E1"
            font.pixelSize: 22
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: "A lightweight Debian-based Linux distribution designed for developers and security professionals."
            color: "white"
            font.pixelSize: 16
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
