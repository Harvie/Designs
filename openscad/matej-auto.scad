$fs= 0.05; //detail kulatin v milimetrech
sroub = 3; //[0.0:5.0]
difference() {
	union() {
		cube([8.5,5,11],center=true); //Hlavni kvadr
		translate([0,2.5,-5.5]) cylinder(6,4.25,4.25); //Podlozka pod sroubem
	}
translate([0,2.5,-10]){cylinder(20,1.5,1.5);} //Dira na zavit sroubu
translate([0,2.5,0.4]){cylinder(11,3.3,3.3);} //Dira na hlavicku sroubu
translate([0,-12,-10]){cylinder(20,10,10);}  //Vykus na roletku
}