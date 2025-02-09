$fn=6;

/* TODO
 - nizsi (70-75mm?)
 - zaoblit hrany
 - sroubovatelna forma
 - musi ji vyndat z formy
 - diry na zavlahu?
*/

module planter(hole=0) {
difference() {
	intersection() {
		union() {
		cylinder(d2=20, d1=20, h=16);
			translate([0,0,-1]) cylinder(d2=17, d1=16.5, h=1); //index
		}
	union() {
		difference() {
			cylinder(d2=20, d1=20, h=16);
			translate([0,0,1]) cylinder(d2=17, d1=13, h=17); //pothole
			translate([0,17.3/2*hole,2]) rotate([0,0,45]) cylinder(d2=12, d1=9.2, h=16, $fn=4); //pothole-join
		}
		translate([-3,0,-2]) scale([1,0.9,1.3]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=5, d2=38, h=16); //balcony
		translate([0,0,-1]) cylinder(d2=17, d1=16.5, h=1); //index
	}
	}
	translate([-3,0,-2]) scale([1,0.9,1.3]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=1, d2=34, h=16); //balcony
}

}

module double() {
	translate([0,0,0]) planter(1);	
	translate([0,17.3,0]) planter(-1);
}

!planter();

//translate([0,0,16.1]) planter();
//translate([0,-20,0]) planter();
//double();

scale(5) difference() {
	translate([-11,-10,-1]) cube([22,37,17]);
	double();
}
