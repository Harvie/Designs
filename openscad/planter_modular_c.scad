// (c) Tomas Mudrunka 2025

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn=6;

/* TODO
 - musi ji vyndat z formy
 - diry na zavlahu?
 - diry na odtok?
*/

module mold_plate(n, d, h=0.4, pitch=17.3, l=1.2) {
	hull() {
		scale([1,l,1]) cylinder(d=d, h=h);
		translate([0,n*pitch,0]) scale([1,l,1]) cylinder(d=d, h=h);
	}
}

module mold_screws(n, d=3.25/5, h=0.4, pitch=17.3, l=1.2) {
	//Konce vert
	translate([0,(0-0.59)*pitch,0]) cylinder(d=d, h=100, center=true);
	translate([0,(n+0.59)*pitch,0]) cylinder(d=d, h=100, center=true);
	//Horiz
	translate([0,(0-0.54)*pitch, 3]) rotate([0,90,0]) cylinder(d=d, h=100, center=true);
	translate([0,(n+0.54)*pitch, 3]) rotate([0,90,0]) cylinder(d=d, h=100, center=true);
	translate([0,(0-0.54)*pitch,10]) rotate([0,90,0]) cylinder(d=d, h=100, center=true);
	translate([0,(n+0.54)*pitch,10]) rotate([0,90,0]) cylinder(d=d, h=100, center=true);
	for(i = [0 : 1 : n]) {
		translate([-1,i*pitch,13]) rotate([0,180,0]) onion(r=5, ang=40, $fn=12);
		if(i!=n) {
			//Stredy vert
			translate([ pitch*0.4,(i+0.5)*pitch,0]) cylinder(d=d, h=100, center=true);
			translate([-pitch*0.4,(i+0.5)*pitch,0]) cylinder(d=d, h=100, center=true);
			//Stredy horiz pin
			translate([0,(i+0.5)*pitch,-0.5]) rotate([0,90,0]) cylinder(d=d, h=100, center=true);
			//Uspora materialu
			translate([ pitch*1.1,(i+0.5)*pitch,0]) cylinder(d=pitch*1.2, h=100, center=true, $fn=8);
			translate([-pitch*1.1,(i+0.5)*pitch,0]) cylinder(d=pitch*1.2, h=100, center=true, $fn=8);
		}
	}
}

module cavity2(n=1, pitch=17.3, d1=13, d2=17, plate=0, skew=-1.5) {
	bot = path_merge_collinear(union([
		for(i = [0 : 1 : n]) union([
			move([skew,i*pitch], hexagon(d=10.2)),
			if(i!=n) move([skew,(i*pitch)+(pitch/2)], square([5.1,pitch/2], center=true))
		])
	]));

	top = path_merge_collinear(union([
		for(i = [0 : 1 : n]) union([
			move([0,i*pitch], hexagon(d=17.2)),
			if(i!=n) move([0,(i*pitch)+(pitch/2)], square([8.6,pitch/2], center=true))
		])
	]));
		
	//!union() { region(bot); right(20) region(top); }

	if(plate != 0) translate([0,0,15]) mold_plate(n=n, d=23, h=plate);
	for(i = [0 : 1 : n]) translate([-3.5,i*pitch,1]) rotate([0,0,30]) cylinder(d1=1, d2=2.5, h=3, center=true); //drain hole
	difference() {
		translate([0,0,8]) rounded_prism(bot, top, height=14, joint_top=-0.7, joint_bot=2.5, joint_sides=1, splinesteps=$fn, anchor="origin"); //pothole
		for(i = [0 : 1 : n]) 
			translate([-3,i*pitch,-2]) scale([1,0.9,1.22]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=5, d2=38, h=15); //balcony clearance
	}

}

module planter2(hollow=1, n=1, pitch=17.3, d1=20, di=16.5) {
	top = path_merge_collinear(union([
		for(i = [0 : 1 : n]) union([
			move([0,i*pitch], hexagon(d=d1)),
			if(i!=n) move([0,(i*pitch)+(pitch/2)], square([8.5,pitch/2], center=true))
		])
	]));
			
	//region(top);

	difference() {
		union() {
			translate([0,0,7.5]) rounded_prism(top, height=15, joint_top=0.1, joint_bot=0.5, joint_sides=0.5, splinesteps=$fn, anchor="origin"); //main hexagon
			for(i = [0 : 1 : n]) translate([0,i*pitch,-1]) rounded_prism(hexagon(d=di), hexagon(d=17), height=1, joint_top=-0.5, joint_bot=0, joint_sides=1, splinesteps=$fn, anchor="bot"); //index
		}
		if(hollow != 0) cavity2(n, pitch);
		for(i = [0 : 1 : n]) translate([-3,i*pitch,-2]) scale([1,0.9,1.22]) rotate([0,90,0]) rotate([0,0,30]) cylinder(d1=1, d2=34, h=15); //balcony
	}
}

module mold_final(units=1) {
	scale(5) {
		difference() {
			union() {
				difference() {
					//translate([-11,-10,-1]) cube([22,37,16]);
					//translate([0,0,0]) minkowski() {
					//cube([2,6,0.0000000001], center=true);
					hull() {
						planter2(n=units, di=22);
						translate([0,0,14]) mold_plate(n=units, d=23, h=1);
					}
					//}
					planter2(hollow=0, n=units);
					translate([-3,0,0]) cube([0.05,100,50], center=true); //split mold
				}
				translate([0,0,0.1]) cavity2(n=units, plate=0.35);
			}
			mold_screws(n=units);
		}
	}
}

//!mold_screws(n=1);
//!cavity2(n=1);
//!planter2(n=1);
//!for(i = [0 : 1: 1]) projection(cut=true) rotate([90,0,0]) translate([-4,0,i*15]) planter2(n=1); //pot profile
//!projection(cut=true) rotate([90,0,0]) translate([-4,-17.3/2,0]) planter2(n=1); //middle profile
//!for(i = [0:1:2]) translate([0,0,i*15]) planter2(n=3-i); //pyramid stack
//!for(i = [0:1:2]) translate([i*23,0,0]) planter2(n=i); //testers
mold_final(1);
