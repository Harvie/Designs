module mobo_shield() {
	union() {
		cube([48,162,2]);
		difference() {
			translate([2,2,0]) cube([44,158,4]);
			translate([4,4,1]) cube([40,154,6]);
		}
	}
}

module mobo_shield_dxf() {
	difference() {
		mobo_shield();
		translate([46,2,-1]) rotate([0,0,90])
			linear_extrude(file = "GA-D525TUD.dxf", height = 50);
	}
}

mobo_shield_dxf();
