$fn=100;
wire_diameter= 1.5;
wr = wire_diameter/2;

module male() {
cylinder(10.4, 5,5);
translate([8.5,0,5.2]) cube([9,10, 14.4], center=true);
	translate([-0.75,0,-1]) cube([19.5,10, 2], center=true);
	translate([4,0,11.4]) cube([10,10, 2], center=true);
	
}

module female() {
difference() {
cylinder(10, 6.5,6.5);
translate([6.2,0,5]) cube([5,20, 20], center=true);	
	translate([0,0,-0.01]) scale([1.0,1.05,1.1]) male();
}
translate([-10,0,6]) cube([9,10, 12], center=true);
//translate([-6,0,-1]) cube([9,8, 2.001], center=true);
}

difference() {
male();
	translate([-10,1.7,1.5]) rotate([0, 90,0]) cylinder(50, wr, wr);
	translate([-10,-1.7,4]) rotate([0, 90,0]) cylinder(50,wr,wr);
	
	translate([-10,1.7,6.5]) rotate([0, 90,0]) cylinder(50, wr,wr);
	translate([-10,-1.7,9]) rotate([0, 90,0]) cylinder(50, wr,wr);
	
	translate([13,0,8.7]) cube([8,8,6], center=true);
	translate([13,0,1.8]) cube([8,8,6], center=true);
	 //translate([3.5,4.2,5]) rotate([0, 90,-15]) cylinder(7, 0.6,0.6);
	 //translate([3.5,-4.2,5]) rotate([0, 90,15]) cylinder(7, 0.6,0.6);
}

translate([-15,0,-2])
difference() {

female();
	translate([-12,-1.7,1.5]) rotate([0, 90,0]) cylinder(10,wr,wr);
	translate([-12,1.7,4]) rotate([0, 90,0]) cylinder(10, wr,wr);
	translate([-12,-1.7,6.5]) rotate([0, 90,0]) cylinder(10, wr,wr);
	translate([-12,1.7,9]) rotate([0, 90,0]) cylinder(10, wr,wr);
	
	translate([-14.5,0,8.25]) cube([8,8,5], center=true);
	translate([-14.5,0,2.8]) cube([8,8,4], center=true);
	
	//translate([1.5, 30,8.5]) rotate([90, 0,0]) cylinder(50, 0.6,0.6);
	//translate([1.5, 30,1.5]) rotate([90, 0,0]) cylinder(50, 0.6,0.6);
	
}