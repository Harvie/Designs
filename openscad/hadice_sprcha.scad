$fn= 100;

difference() {
%translate([0,0,0.1]) cylinder(d1=23, d2=20, h=30);
union() {
	translate([0,0,16]) cylinder(d=12.5, h=30);
	cylinder(d=13.5, h=5);
	cylinder(d=11.5, h=30);
	translate([0,0,13]) cylinder(d=13.5, h=7);
}
}
//translate([0,0,-12.2]) cylinder(d=23, h=12);