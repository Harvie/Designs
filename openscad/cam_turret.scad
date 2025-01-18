$fn=100;
dia=45;

module camball(d, cutout=0, lens=30) {
	sphere(d=d);
	if(cutout) {
		union() {
			sphere(d=d);
			translate([0,0,-d]) cylinder(d=d-4, h=d);
		}
		hull() for ( i = [-10 : 20 : 90] ) {
			rotate([i,0,0]) cylinder(d1=d/1.5, d2=d/1.3, h=d);
		}
	}
}

module screw() {
	cylinder(d=5, h=100, center=true);
	rotate([0,  0,0]) translate([0,0,5]) cylinder(d=10, h=100);
	rotate([0,180,0]) translate([0,0,5]) cylinder(d=10, h=100);
}

module ballholder(d) {
	difference() {
		hull() {
			sphere(d=d+4);
			translate([0,0,-d/2-5]) cylinder(d=d+30, h=5);
		}
		translate([0,-500,0]) cube([1.5,1000,1000], center=true);
		translate([0,-d/1.5,-d/2.1]) rotate([0,90,0]) screw();
	}
}

module baseplate(d) {
	difference() {
		union() {
			translate([0,0,-d/2-2]) cylinder(d1=d+3, d2=d, h=2);
			translate([0,0,-d/2-5]) cylinder(d1=d, d2=d+3, h=3);
			translate([0,0,-d/2-9.99]) cylinder(d=d+30, h=5);
		}
		cylinder(d=d-10, h=1000, center=true);
		
		//Standart EU junction box mounting holes
		for(i = [0 : 90 : 360]) {
			rotate([0,0,i]) translate([30,0,0])
			cylinder(d=4, h=1000, center=true);	
		}
	}
}



//camball(d=dia, cutout=0);
%difference() {
	ballholder(dia);	
	camball(d=dia, cutout=1);
	baseplate(dia);
}

//camball(d=dia, cutout=1);
baseplate(dia);


