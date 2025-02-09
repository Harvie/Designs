module planter(hole=0) {
difference() {
	intersection() {
		union() {
		cylinder(d2=20, d1=20, h=16, $fn=6);
			translate([0,0,-1]) cylinder(d2=16, d1=14, h=1, $fn=6); //index
		}
	union() {
		difference() {
			cylinder(d2=20, d1=20, h=16, $fn=6);
			translate([0,0,2]) cylinder(d2=17, d1=13, h=16, $fn=6); //pothole
			translate([0,17.3/2*hole,2]) rotate([0,0,45]) cylinder(d2=12, d1=9.2, h=16, $fn=4); //pothole2
		}
		translate([-2,0,-2]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=5, d2=38, h=12, $fn=6); //balcony
		translate([0,0,-1]) cylinder(d2=16, d1=16, h=1, $fn=6); //index
	}
	}
	translate([-2,0,-2]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=1, d2=34, h=12, $fn=6); //balcony
}

}

module double() {
	translate([0,0,0]) planter(1);	
	translate([0,17.3,0]) planter(-1);
}


//translate([0,0,16]) planter();
translate([0,-20,0]) planter();
double();
