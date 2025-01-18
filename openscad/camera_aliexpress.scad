$fn=256;

module camera(zclr=0) {
	translate([0,0,-zclr/2]) cube([21.5,21.5,18+zclr], center=true);
	cylinder(d=18, h=9+5+zclr);
}

module camera_ball() {
	difference() {
		intersection() {
			sphere(d=45);
			translate([0,0,2]) cube([1000,1000,35], center=true);
		}
		translate([0,0,6.5]) {
			camera(zclr=100);
		}
	}
}

camera_ball();
//translate([0,0,6.5]) camera();