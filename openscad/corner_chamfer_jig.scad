//Corner cutting jig

difference() {
	cylinder(d=30, h=13, $fn=12);
	translate([0,0,-4]) rotate([45,-atan(1/sqrt(2)),0]) cube(50);
}