$fn=100;
difference() {
cube([30,30, 10], true);
    cylinder(20,3.175/2,3.175/2);
    translate([5,0,-10]) cylinder(50,3.175/2,3.175/2);
    translate([5,5,-10]) cylinder(20,3/2,3/2);
    translate([0,5,-10]) cylinder(20,3.2/2,3.2/2);
    translate([10,0,-10]) cylinder(20,4/2,4/2);
    
}