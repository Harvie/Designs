$fn=200;

translate([0,0,-15]) intersection() {
    difference() {
        cylinder(15,12.5,12.5);
        translate([0,0,-2]) cylinder(20,5,5);
    }
    translate([0,20,1]) rotate([90,0,0]) cylinder(40,14,14);
}