$fn=100;

difference() {
cylinder(h=8, d=41);
cylinder(h=9, d=35);
rotate([0,0,45]) { cube([35,35, 9],center=false); }
}
translate([-8,-32,0]) difference() {
	cube([16, 15, 14]);

translate([-50,0,4]) cube([100,2,6]);
translate([-50,2,2]) cube([100,2,10]);
translate([0,12,17]) rotate([60,0,0]) cube([50,10,20],center=true);
}


