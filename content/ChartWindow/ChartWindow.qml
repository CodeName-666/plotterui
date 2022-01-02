import QtQuick 2.15


ChartWindowUi{

    Timer {
        id: refreshTimer
        //interval: 1 / 60 * 1000 // 60 Hz
        interval: 250
        property var sinVal: 0
        property var count: 1
        running: true
        repeat: false
        onTriggered: {
            //xAsis.max++;
            //xAsis.tickCount++;
            if(sinVal <= 360)
                sinVal ++;
            else
                sinVal = 0

            var xPoint = (xAsis.max - xAsis.min) / 2 + xAsis.min;
            var yPoint = Math.sin1(sinVal)
            console.log("X = ", xPoint, "Y = ", yPoint);

            linseries.append(xPoint,yPoint);

            if(count >= 90)
            {
              chart.scrollRight(8.5);
            }

            count++;
            //linseries.remove(0)
        }
    }

    //xAsis.onRangeChanged: chart.scroll(min,max)
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
