$fn=100;
dia=45;
tol=0.3; //Worst case scenario for well maintained ender3 :-)

module camball(d, cutout=0, toler=0, lens=30) {
	sphere(d=d+(toler*2));
	if(cutout) {
		//Hole to insert the ball
		translate([0,0,-d]) cylinder(d1=d+4, d2=d-4, h=d);
		
		//Range of ball rotation:
		hull() for ( i = [-10 : 20 : 90] ) {
			rotate([i,0,0]) cylinder(d1=d/1.5, d2=d/1.3, h=d);
		}
	}
}

module screw() {
	rotate([0,0,30]) cylinder(d=5, h=100, center=true, $fn=6);
	$fn=6;
	rotate([0,  0,40]) translate([0,0,20]) cylinder(d=10, h=100);
	rotate([180,0,40]) translate([0,0,20]) cylinder(d=10, h=100);
}

module ballholder(d) {
	difference() {
		//Outer cone shape
		hull() {
			sphere(d=d+4);
			translate([0,0,-d/2-5]) cylinder(d=d+30, h=5);
		}
		
		//This makes everything more flexy
		hull() {
			sphere(d=d+4);
			translate([0,d/2,-d/2-10]) cylinder(d=d/2, h=10);
		}
		
		//Split to make it clamp
		translate([0,-500,0]) cube([1.5,1000,1000], center=true);
		
		//Clamp screw hole
		translate([0,-d/1.5,-d/2.1]) rotate([0,90,0]) screw();
	}
}

module baseplate(d, toler=0) {
	dt = toler*2;
	difference() {
		//Flange
		union() {
			translate([0,0,-d/2-2]) cylinder(d1=d+3+dt, d2=d+dt, h=2);
			translate([0,0,-d/2-5]) cylinder(d1=d+dt, d2=d+3+dt, h=3);
			translate([0,0,-d/2-9.99]) cylinder(d1=d+30+dt, d2=d+30+dt, h=5+toler);
		}
		
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



camball(d=dia, cutout=0);
%difference() {
	ballholder(dia);	
	camball(d=dia, cutout=1, toler=tol);
	baseplate(dia, toler=tol);
}

//camball(d=dia, cutout=1);
baseplate(dia);


