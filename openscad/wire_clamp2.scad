$fn=50;

wire_diameter = 1.5;
wr = wire_diameter /2;

bus_diameter = 1.6;
br = bus_diameter / 2;

module latch() {
		hull() {
cylinder(8,1.5,1.5);
translate([10,0,0]) cylinder(8,2.5,2.5);
	}
	}

module lever(hole=true) {

difference() {
latch();
if(hole) translate([5.2,-4.5,0]) cylinder(8,5,5);
}

translate([10,-1,2.5]) rotate([0,0,8]) cube([8,3,3]);
translate([17.5,2,0]) cylinder(8,2.5,2.5);

}

//lever(true);
difference() {
	translate([-0.5,0,0]) scale([1,1,0.9999]) minkowski() {
		union() {
		hull() {
		 scale([1.1,1,1])latch();
		 rotate([0,0,20]) scale([1.1,1,1]) latch();
			translate([-2.1,0,0]) cylinder(8,1,1);
	    }
		
	}
		cylinder(0.000001,2,2);
	}
	translate([0,0,0]) lever(false);
	translate([0,0,0]) rotate([0,0,20]) scale([1.1,1.1,1.1]) lever(false);
	translate([12,-2,2]) rotate([0,0,26]) cube([8,9,4]);
	translate([14.5,-5,0]) rotate([0,0,-1]) cube([8,9,8]);
	
	translate([-0.8,10,1.5]) rotate([90,0,0]) cylinder(20,wr,wr);
	translate([-0.8,10,4]) rotate([90,0,0]) cylinder(20,wr,wr);
	translate([-0.8,10,6.5]) rotate([90,0,0]) cylinder(20,wr,wr);
	translate([-2.1,0,0]) cylinder(20,br,br);
	
}




translate([0.6,0.3,0]) rotate([0,0,19])
lever();