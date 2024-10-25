module planter_cavity(void=0, da=70, db=83) {
	translate([0,0,14.1]) difference() {
		hull() {
			translate([0,0,73]) cylinder(d1=db-2, d2=db, h=10, $fn=12);
			cylinder(d1=da-5, d2=da, h=5, $fn=64);
		}
		if(void) translate([0,0,-14.1+2.5]) scale([0.97,0.97,1]) planter_cavity();
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
						translate([0,0,40]) cylinder(d2=35, d1=66, h=10, $fn=6);
						translate([0,0,49.2]) cylinder(d1=20, d2=100, h=10, $fn=6);
					}
				}
			}
			cylinder(d=90, h=94);
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
		translate([0,0,90]) cylinder(d=103, h=7);
		translate([0,0,0.001]) rotate([0,0,90])
			scale([1.03,1.03,1.001]) planter();
		translate([-60,0,97/2]) cube([3,7,97], center=true);
		translate([ 60,0,97/2]) cube([3,7,97], center=true);
		translate([  0,0,97/2]) cube([120,4,96.99], center=true);
	}
	rotate([0,0,90]) planter();
	rotate([0,0,90]) scale([1.01,1.01,1]) planter_cavity();
	if(half == 1) translate([-100,0,0]) cube(200);
	if(half == 2) translate([-100,-200,0]) cube(200);
}
}

//planter();
//planter_cavity();

planter_cavity(3);
rotate([180,0,0]) {
	translate([0,-12,0]) planter_mold(half=1);
	translate([0,12,0]) planter_mold(half=2);
}
