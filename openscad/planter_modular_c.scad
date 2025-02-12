include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn=6;

/* TODO
 - zaoblit hrany
 - sroubovatelna forma
 - musi ji vyndat z formy
 - diry na zavlahu?
*/

module cavity2(n=6, pitch=17.3, d1=13, d2=17) {
	bot = path_merge_collinear(union([
		for(i = [0 : 1 : n]) union([
			move([0,i*pitch], hexagon(d=13)),
			if(i!=n) move([0,(i*pitch)+(pitch/2)], square([7.5,pitch/2], center=true))
		])
	]));

	top = path_merge_collinear(union([
		for(i = [0 : 1 : n]) union([
			move([0,i*pitch], hexagon(d=17)),
			if(i!=n) move([0,(i*pitch)+(pitch/2)], square([8.5,pitch/2], center=true))
		])
	]));
		
	//region(bot);

	for(i = [0 : 1 : n]) translate([-4,i*pitch,1]) sphere(1); //drain hole
	difference() {
		translate([0,0,8]) rounded_prism(bot, top, height=14, joint_top=-0.5, joint_bot=0.5, joint_sides=1, splinesteps=$fn, anchor="origin"); //pothole
		for(i = [0 : 1 : n]) 
			translate([-3,i*pitch,-2]) scale([1,0.9,1.22]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=5, d2=38, h=15); //balcony clearance
	}
}

module planter2(hollow=1, n=1, pitch=17.3, d1=20) {
	top = path_merge_collinear(union([
		for(i = [0 : 1 : n]) union([
			move([0,i*pitch], hexagon(d=d1)),
			if(i!=n) move([0,(i*pitch)+(pitch/2)], square([8.5,pitch/2], center=true))
		])
	]));
			
	//region(top);

	difference() {
		union() {
			translate([0,0,7.5]) rounded_prism(top, height=15, joint_top=0.5, joint_bot=0.5, joint_sides=0.5, splinesteps=$fn, anchor="origin"); //main hexagon
			for(i = [0 : 1 : n]) translate([0,i*pitch,-1]) rounded_prism(hexagon(d=16.5), hexagon(d=17), height=1, joint_top=-0.5, joint_bot=0.5, joint_sides=1, splinesteps=$fn, anchor="bot"); //index
		}
		if(hollow != 0) cavity2(n, pitch);
		for(i = [0 : 1 : n]) translate([-3,i*pitch,-2]) scale([1,0.9,1.22]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=1, d2=34, h=15); //balcony
	}
}

module double(ho=1) {
	translate([0,0,0])		if(ho==-1) cavity( 1); else planter( 1, hollow=ho);
	translate([0,17.3,0])	if(ho==-1) cavity(-1); else planter(-1, hollow=ho);
}

//%cavity();
//cavity2();
planter2();
//!double()

/*
union() {
	rotate([0,0,60]) translate([0,0,15.5]) planter();
	//translate([0,0,31]) double();
	//translate([0,0,15.5]) double();
	translate([0,-20,0]) planter();
	double();
}
*/
/*
scale(5) {
	difference() {
		//translate([-11,-10,-1]) cube([22,37,16]);
		translate([0,0,0]) minkowski() {
			cube([2,6,0.0000000001], center=true);
			hull() double();
		}
		double(ho=0);
		translate([-4,0,0]) cube([0.01,100,50], center=true); //split mold
	}
	
	translate([20,0,0]) double(ho=-1);
	 
}
*/
