//Z kostky by melo koukat 5-6mm konektoru!

$fn=32;


difference() {
	hull() {
		intersection() {
			translate([-4,-3/2,0]) cube([26,27,33.9]);
			translate([7,12,0]) cylinder(d=30, h=33.9, $fn=100);
		}
		translate([9,23.5/2,-7]) cylinder(d=20, h=7);
	}
	union() {
	cube([2,24,34]);
		intersection() {
	translate([2,2,0]) cube([18,20,34]);
			translate([7,12,0]) cylinder(d=26, h=33.9, $fn=100);
		}
	translate([-2,2,0]) cube([2,20,34]);
	translate([7+4,24/2,-20]) cylinder(d=10.2, h=100); //same

	difference() {
	translate([20,6.5,30]) rotate([90,90,90])
		linear_extrude(3) text("USB");
		translate([7,12,0]) cylinder(d=29.6, h=33.9, $fn=100);
	}
	}
}

difference() {
	translate([7+4,24/2,0]) cylinder(d=15, h=2);
	translate([7+4,24/2,-20]) cylinder(d=10.2, h=100); //same
}
