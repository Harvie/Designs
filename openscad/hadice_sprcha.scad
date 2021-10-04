$fn= 100;

rotate([-90,0,0])
difference() {
translate([0,0,0.1]) cylinder(d1=23, d2=20, h=30);
union() {
	translate([0,0,16]) cylinder(d=12.5, h=30);
	cylinder(d=13.5, h=5);
	cylinder(d=11.5, h=30);
	translate([0,0,13]) cylinder(d=13.5, h=7);
}
rotate([90,0,0]) union() {
	translate([7.5,9,-6]) cylinder(d=1.6, h=12);
	translate([7.5,9,-6-10]) cylinder(d=3.8, h=1.7+10);
	translate([7.5,9,6-1.7]) cylinder(d=3.8, h=1.7+10);
}
rotate([90,0,180]) union() {
	translate([7.5,9,-6]) cylinder(d=1.6, h=12);
	translate([7.5,9,-6-10]) cylinder(d=3.8, h=1.7+10);
	translate([7.5,9,6-1.7]) cylinder(d=3.8, h=1.7+10);
}
translate([0,0,9]) rotate_extrude() translate([10.5,0,0]) circle(1);
translate([0,0,21]) rotate_extrude() translate([9.9,0,0]) circle(1);
translate([-20,0,0]) cube(40);
}
//translate([0,0,-12.2]) cylinder(d=23, h=12);
