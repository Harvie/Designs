// Profil kolejnice

module slider(len=20, margin=0) {
	translate([-10,0,0]) cylinder(h=len, r=8+margin, $fn=6);
	translate([1,0,0]) cylinder(h=len, r=8+margin, $fn=6);	
}

// Drzak na tyc

translate([20+(35/2),0,0]) 
difference() {
	union() {
		cylinder(h=14, d=41);
		translate([-17,-10,7]) rotate([-90,0,0]) slider(len=20);
	}
	cylinder(h=30, d=35, center=true);
	rotate([0,0,-45]) cube([35,35, 20],center=false);
	translate([-34,0,0]) cube([4,40,40], center=true);
}

// Kolejnice

$fn=30;
//%translate([20.5,0,0])
difference() {
	translate([-12,0,30]) cube([17, 20, 60], center=true);
	difference() {
		slider(len=60, margin=0.2);
		//retencni vystupek
		translate([-10,-8,58.5]) sphere(r=1.5);
		translate([-10,-8,1.5]) sphere(r=1.5);
	}
	
	//diry na srouby
	translate([0,0,5]) rotate([0,-90,0]) cylinder(d=4, h=30);
	translate([0,0,55]) rotate([0,-90,0]) cylinder(d=4, h=30);
}




