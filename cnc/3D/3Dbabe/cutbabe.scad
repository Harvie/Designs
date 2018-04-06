module babe(a=0) {
rotate([5,a*180,0]) scale(11) translate([0,-9,0.65]) rotate([-90,0,0]) import("PrintBabe-PrintBabe2-Standing__.stl");
}

module cutcube(a=10) {
    translate([0,0,a/2]) cube([100,100,a], center=true);
    }

intersection() {
babe();
cutcube(20);
}