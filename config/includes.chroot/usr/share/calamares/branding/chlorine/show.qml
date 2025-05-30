import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Image {
            id: background1
            source: "slide1.png"
            width: 800; height: 600
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 50
            text: "Welcome to Chlorine Linux"
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.Center
            font.pixelSize: 22
            font.bold: true
            color: "#35b9ab"
            style: Text.Raised
            styleColor: "black"
        }
    }

    Slide {
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 50
            text: "Thank you for choosing Chlorine Linux"
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.Center
            font.pixelSize: 22
            font.bold: true
            color: "#35b9ab"
            style: Text.Raised
            styleColor: "black"
        }
    }

    function onActivate() { }
    function onLeave() { }
}
