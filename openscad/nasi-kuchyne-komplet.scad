// Profil kolejnice

module slider(len=20, margin=0) {
	translate([-10,0,0]) cylinder(h=len, r=8+margin, $fn=6);
	translate([1,0,0]) cylinder(h=len, r=8+margin, $fn=6);	
}

// Drzak na tyc

translate([20+(34/2),0,0]) 
difference() {
	union() {
		cylinder(h=14, d=40);
		translate([-16.5,-10,7]) rotate([-90,0,0]) slider(len=20);
	}
	cylinder(h=30, d=34, center=true);
	rotate([0,0,-45]) cube([35,35, 20],center=false);
	translate([-33.4,0,0]) cube([4,40,40], center=true);
}

// Kolejnice

$fn=30;
//%translate([20.5,0,0])
difference() {
	translate([-12,0,30]) cube([17, 20, 60], center=true);
	difference() {
		slider(len=60, margin=0.2);
		//retencni vystupek
		translate([-10,-8,58.5]) sphere(r=1.6);
		translate([-10,-8,1.5]) sphere(r=1.6);
	}
	
	//diry na srouby
	translate([-15,0,5]) rotate([0,-90,0]) cylinder(d2=3, d1=7, h=6);
	translate([-15,0,55]) rotate([0,-90,0]) cylinder(d2=3, d1=7, h=6);
}




