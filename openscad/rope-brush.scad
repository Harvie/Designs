$fn=8;

diameter = 30;
height = 20;

difference() {
	cylinder(h=height, d=7, $fn=32);
	cylinder(h=height, d=4, $fn=32);
}
//cylinder(h=1 , d=10, $fn=32);

difference() {
	cylinder(h=height, d=diameter+8);
	cylinder(h=height, d=diameter+0);
}

difference() {
for (h = [0 : 1 : height-2]) {
for (i = [0 : 4 : 180]) {
	translate([0,0,1+h]) rotate([90,0,i+(h*3)]) cube([0.2,0.2,diameter+3], center=true);
}
}
cylinder(h=height, d=4, $fn=32);
}