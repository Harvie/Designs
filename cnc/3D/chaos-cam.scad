$fn=100;

translate([0,0,-20]) difference() {
cube([60,40,20]);
translate([30,20,20]) rotate([90,0]) cylinder(30,10,10);
    translate([10,20,-10]) cylinder(40,4,4);
    translate([50,20,-10]) cylinder(40,4,4);
}
