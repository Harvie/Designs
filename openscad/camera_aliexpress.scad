module camera(zclr=0) union() {
	cylinder(d=19, h=9+5+zclr, $fn=24); //lens
	cube([21.5,21.5,18], center=true); //body
	if(zclr) hull() {
		translate([0,0,-9]) cube([21.5,21.5,1], center=true);
		translate([0,0,-67]) cylinder(d=31, h=45);
	}
	
}

module camera_ball() {
	difference() {
		intersection() {
			sphere(d=45, $fn=256);
			translate([0,0,2]) cube([1000,1000,35], center=true);
		}
		translate([0,0,6.5]) {
			camera(zclr=100);
		}
		//translate([0,0,-45/1.5]) sphere(d=45);
	}
}

//sphere(d=45);
rotate([180,0,0]) {
	camera_ball();
	//translate([0,0,6.5]) camera(zclr=100);
}