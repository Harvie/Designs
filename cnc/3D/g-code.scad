module tool() {
    //simulate 1/8'' flat end mill
    cylinder(20,1.5875,1.5875, $fn=10);
}

/*
module tool() {
    //show toolpaths as thin lines or simulate 3d printer
    sphere(0.1, $fn=10);
}
*/

module path(a, b) {
    hull() {
        translate(a) tool();
        translate(b) tool();
    }
}

module gcode(vec) {
    for(i = [0:len(vec)]) path(vec[i-2],vec[i-1]);
}

//vector generated from g-code
vec = [
[0,0,0],
[0,0,-10],
[10,20,-10],
[20,10,-10],
[30,10,-10],
[30,10,0],
];

difference() {
    //stock material
    %translate([-10,-10,-20]) cube([50,40,20]);
    //object generated from g-code
    gcode(vec);
}