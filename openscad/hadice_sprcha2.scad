$fn=100;

module hose_ferule(t=0.3) { //t = tolerance
	//thread side
	translate([0,0,2]) hull() rotate_extrude() translate([(t+13.5-4)/2,0,0]) circle(d=4);
	cylinder(d=t+13.5, h=2);

	//crimp
	cylinder(d=t+12, h=30);

	//hose side
	translate([0,0,10.5]) {
		translate([0,0,2]) hull() rotate_extrude() translate([(t+13.5-4)/2,0,0]) circle(d=4);
		translate([0,0,6.5]) hull() rotate_extrude() translate([(t+13.5-4)/2,0,0]) circle(d=4);
		translate([0,0,2]) cylinder(d=t+13.5, h=6.5-2);
	}

	//hose
	translate([0,0,15]) cylinder(d=t+12.5, h=30);
	translate([0,0,29]) cylinder(d1=t+12.5, d2=20, h=5); //inner bevel
}

module hose_cone() {
	difference() {
		//cone
		translate([0,0,0.01]) cylinder(d1=23.5, d2=20.5, h=30);
		//outer bevel
		rotate_extrude() rotate([0,0,45]) translate([15,30.4,0]) square(5, center=true);
		hose_ferule();
	}
}

module snap_fit(t=0) {
	hull() {
		translate([-9,-2,0]) cylinder(d=2+t, h=31);
		translate([-200,-2,0]) cylinder(d=2+t, h=31);
	}
	translate([-11.5,0,0]) cube([5+t,2+t,66], center=true);
	translate([-9.3,0.6,0]) rotate([0,0,55]) cube([2.5+t,2.5+t,66], center=true);
}

module cone_cutout(t=0)  {
	difference() {
		hose_cone();
		translate([-25,0,0]) cube(50);
	
		snap_fit(t);
		mirror([1,0,0]) snap_fit(t);
	}
}

// Instantiate

cone_cutout(t=0.3);

translate([0,5,0]) difference() {
	hose_cone();
	cone_cutout();
}
