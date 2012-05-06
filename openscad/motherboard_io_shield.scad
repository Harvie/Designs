module mobo_shield() {
	union() {
		cube([48,162,2]);
		difference() {
			translate([2,2,0]) cube([44,158,4]);
			translate([4,4,1]) cube([40,154,6]);
		}
	}
}

mobo_shield();
