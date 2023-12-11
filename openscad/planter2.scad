module planter_cavity() {
	translate([0,0,15]) cylinder(d1=70, d2=80, h=83, $fn=18);
}

module planter() {

difference() {
translate([0,0,15]) for (h = [0 : 1 : 2] ){
translate([0,0,h*31])
for (r = [0 : 40 : 360] ){
	rotate([90,90,r+20*(h%2)])
	difference() {
	translate([0,0,25]) hull() {
		cylinder(d=35, h=25, $fn=6);
		rotate([0,0,45]) cylinder(d=60, h=12, $fn=4);
	}
	translate([0,0,70]) sphere(d=50, $fn=6);
	}
}
}

translate([0,0,-50]) cylinder(d=140, h=50);
translate([0,0,2.5*31+15]) cylinder(d=140, h=50);
planter_cavity();
}
cylinder(d=90, h=15.1);

}

module planter_mold(half=0) {
difference() {
	union() {
		//translate([0,0,0.1]) cylinder(d=110, h=100);
		translate([0,0,90]) cylinder(d=108, h=7);
		minkowski() {
			rotate([0,0,90]) planter();
			translate([0,0,0.001]) cylinder(r=2, h=0.01);	
		}
		translate([-60,0,48.5]) cube([3,7,97], center=true);
		translate([ 60,0,48.5]) cube([3,7,97], center=true);
		translate([  0,0,48.5]) cube([120,4,97], center=true);
	}
	rotate([0,0,90]) planter();
	rotate([0,0,90]) planter_cavity();
	if(half == 1) translate([-100,0,0]) cube(200);
	if(half == 2) translate([-100,-200,0]) cube(200);
}
}

planter_cavity();
rotate([180,0,0]) {
	translate([0,-12,0]) planter_mold(half=1);
	translate([0,12,0]) planter_mold(half=2);
}