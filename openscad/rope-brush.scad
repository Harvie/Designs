$fn=8;

diameter = 30;
height = 20;

difference() {
	cylinder(h=height, d=7, $fn=64);
	cylinder(h=height, d=4, $fn=64);
}
//cylinder(h=1 , d=10, $fn=64);

difference() {
	cylinder(h=height, d=diameter+6);
	cylinder(h=height, d=diameter+0);
	for (h = [0 : 1 : height-2]) { //SAME!
		translate([0,0,1+h]) cylinder(h=0.2, d=diameter+1.6, center=true);
	}
}

difference() {
for (h = [0 : 1 : height-2]) { //SAME!
for (i = [0 : 4.5 : 180]) {
	translate([0,0,1+h]) rotate([90,0,i+(h*3)]) cube([0.2,0.2,diameter+2], center=true);
}
}
cylinder(h=height, d=4, $fn=32);
}