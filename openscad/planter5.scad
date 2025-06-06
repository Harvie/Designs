module planter_cavity(void=0, da=65, db=84) {
	rotate([0,0,10]) translate([0,0,14.1]) difference() {
		hull() {
			translate([0,0,73]) cylinder(d1=db-2, d2=db, h=10, $fn=9);
			cylinder(d1=da-5, d2=da, h=5, $fn=64);
		}
		if(void) rotate([0,0,-10]) translate([0,0,-14.1+2.5]) scale([0.97,0.97,1]) planter_cavity();
	}
}

module planter() {
	difference() {
		union() {
			translate([0,0,15]) for (h = [0 : 1 : 2] ){
				translate([0,0,h*31.5])
				for (r = [0 : 40 : 360] ){
					rotate([90,90,r+20*(h%2)])
					difference() {
						translate([0,0,37+h*3]) cylinder(d2=35, d1=47.5, h=7, $fn=6);
						translate([0,0,42.5+h*3]) cylinder(d1=21, d2=50, h=10, $fn=6);
					}
				}
			}
			cylinder(d1=80, d2=98, h=94, $fn=64);
	    }

		translate([0,0,-50]) cylinder(d=140, h=50);
		translate([0,0,2.5*31+15]) cylinder(d=140, h=50);
		planter_cavity();
	}
	
}

module planter_mold(half=0) {
difference() {
	union() {
		//translate([0,0,0.1]) cylinder(d=110, h=100);
		translate([0,0,90]) cylinder(d=103, h=7, $fn=128);
		translate([0,0,0.001]) rotate([0,0,90])
			scale([1.03,1.03,1.001]) planter();
		translate([-60,0,97/2]) cube([3,7,97], center=true);
		translate([ 60,0,97/2]) cube([3,7,97], center=true);
		translate([  0,0,97/2]) cube([120,4,96.99], center=true);
	}
	rotate([0,0,90]) planter();
	rotate([0,0,90]) scale([1.005,1.005,1]) planter_cavity();
	if(half == 1) translate([-100,0,0]) cube(200);
	if(half == 2) translate([-100,-200,0]) cube(200);

	//Screw holes
	$fn=12;
	translate([ 56, 0, 80]) rotate([90,0,0]) cylinder(d=3.5, h=100, center=true);
	translate([ 56, 0, 45]) rotate([90,0,0]) cylinder(d=3.5, h=100, center=true);
	translate([ 56, 0, 10]) rotate([90,0,0]) cylinder(d=3.5, h=100, center=true);
	translate([-56, 0, 80]) rotate([90,0,0]) cylinder(d=3.5, h=100, center=true);
	translate([-56, 0, 45]) rotate([90,0,0]) cylinder(d=3.5, h=100, center=true);
	translate([-56, 0, 10]) rotate([90,0,0]) cylinder(d=3.5, h=100, center=true);
}
}


if(0) { //Just planter
	planter();
	//planter_cavity();
} else {
	planter_cavity(3);
	//rotate([180,0,0]) {
	mirror([0,0,1]) {
		translate([0,-12,0]) planter_mold(half=1);
		translate([0,12,0]) planter_mold(half=2);
	}
}