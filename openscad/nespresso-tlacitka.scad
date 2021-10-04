$fn=80;

difference() {
	union() {
		minkowski() {
			cube([44,24,0.1], center=true);
			sphere(r=3);
		}
		difference() {
			translate([0,-2,-1.3]) rotate([-15,0,0]) union() {
				translate([11.25,2.5,0]) cylinder(h=13, d=17, center=true);
				translate([-11.25,2.5,0]) cylinder(h=13, d=17, center=true);
			}
			//translate([0,15,0]) cube([60,20,20], center=true);
		}
	}
	translate([0,0,-30]) cube([60,60,60], center=true);
	translate([11.25,2.5,0]) cylinder(h=20, d=13, center=true);
	translate([-11.25,2.5,0]) cylinder(h=20, d=13, center=true);
}