

var rect_pos = 0
var rect_start = 1

function sinus(x,f,A) {

    return A * Math.sin(2*Math.PI* f * x);
}

function cosinus(x,f,A) {

    return A * Math.sin(2*Math.PI* f * x);
}


function rect(x, low, high, width) {
    if(rect_start == 1) {
        rect_pos = low;
        rect_start = 0;
    }

    let edge = (x % width)

    if(edge)
    {
        if(rect_pos == low)
            rect_pos = high;
        else
            rect_pos = low;
    }
    return rect_pos
}