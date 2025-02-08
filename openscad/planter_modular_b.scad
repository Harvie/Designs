module planter() {
difference() {
	intersection() {
		cylinder(d2=20, d1=20, h=12, $fn=6);
	union() {
		difference() {
			cylinder(d2=20, d1=20, h=12, $fn=6);
			translate([0,0,2]) cylinder(d2=16, d1=16, h=12, $fn=6);
		}
		translate([0,0,-1]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=5, d2=30, h=10, $fn=6);
	}
	}
	translate([0,0,-1]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=1, d2=26, h=10, $fn=6);
}
}

!translate([0,0,0]) planter();
translate([0,0,12]) planter();
translate([0,17.3,0]) planter();