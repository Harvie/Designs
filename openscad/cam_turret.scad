$fn=64;
dia=45; //Diameter of ball, TODO: some things are not ready to change this
tol=0.3; //Worst case scenario tolerance for well maintained ender3 :-)

module camball(d, cutout=0, toler=0, lens=30) {
	//This is shape of sphere cavity in the chasis, not actual ball to be printed
	//You need to print ball that fits particular camera module you want to use

	//Actual sphere
	sphere(d=d+(toler*2));

	//Additional clearances to be removed from ball holder
	if(cutout) {
		//Hole to insert the ball
		translate([0,0,-d]) cylinder(d1=d+4, d2=d-4, h=d);
		
		//Range of ball rotation:
		hull() for ( i = [0 : 10 : 70] ) {
			rotate([i,0,0]) cylinder(d1=d/1.5, d2=d*1.5, h=d);
		}
	}
}

module screw() {
	//Main screw hole, this can be improved to fit whatever screw/bolt you use
	rotate([0,0,30]) cylinder(d=3, h=100, center=true, $fn=6);
	rotate([0,0,30]) cylinder(d=5, h=100,            , $fn=6);
	$fn=6;
	rotate([0,  0,53]) translate([0,0,15]) cylinder(d=12, h=100);
	rotate([180,0,53]) translate([0,0,15]) cylinder(d=12, h=100);
}

module ballholder(d) {
	//Basic shape of chasis (without ball and baseplate cutouts)
	difference() {
		//Outer cone shape
		hull() {
			sphere(d=d+5);
			translate([0,0,-d/2-5]) cylinder(d=d+30, h=5);
		}
		
		//This makes everything more flexy
		hull() {
			sphere(d=d-4);
			translate([0,d/1.85,-d/2-10]) cylinder(d=d/2, h=10);
		}
		
		//Split to make it clamp
		translate([0,-500,0]) cube([2,1000,1000], center=true);
		
		//Clamp screw hole
		translate([0,-d/1.5,-d/2.4]) rotate([0,90,0]) screw();
	}
}

module baseplate(d, toler=0) {
	//This is mounting baseplate that holds and rotates whole thing on a wall

	dt = toler*2; //Tolerance for diameters
	difference() {
		//Flange
		union() {
			//This can be made higher to support ball from back
			//and prevent it from being pushed in:
			translate([0,0,-d/2-2]) cylinder(d1=d+3+dt, d2=d+dt-9, h=8);
			translate([0,0,-d/2-5]) cylinder(d1=d+dt, d2=d+3+dt, h=3);
			translate([0,0,-d/2-9.99]) cylinder(d1=d+30+dt, d2=d+30+dt, h=5+toler);
		}

		//Ball clearance
		sphere(d=d+dt);

		//Hole for cables
		cylinder(d=d-10, h=1000, center=true);
		
		//Standart EU junction box mounting holes (60mm pitch)
		if(!toler) for(i = [0 : 90 : 360]) {
			rotate([0,0,i]) translate([30,0,0]) {
				cylinder(d=4, h=1000, center=true);
				translate([0,0,-29]) cylinder(d1=7, d2=10, h=2.1);
			}
		}

	}
}

module ballholder_full(d) {
	//This is final shape of chasis that holds ball to baseplate
	//This time ball and baseplate cavities are added to it

	difference() {
		ballholder(dia);
		camball(d=dia, cutout=1, toler=-0.5);
		baseplate(dia, toler=tol);
	}
}

//camball(d=dia, cutout=0);
ballholder_full(d=dia);
//camball(d=dia, cutout=1);
baseplate(dia);


