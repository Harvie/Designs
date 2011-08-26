/*
 * TODO
 ** make more parametric
 ** add parameter to specify number of wires/pins
 */

$fn=10; //Minimum nuber of circle segments

module conn_male(size=23, thickness=1.5, full=false) {
	difference() {
		union() {
			translate([0,size*0.3,0]) cube([size-(thickness*2),(size-(thickness*2))*2,size-(thickness*2)], center=true);
			translate([size/3,(size/3)-thickness]) rotate([0,0,145]) cube([size*0.2,size/4,size-(thickness*2)], center=true);
		}
		if(!full) {
			translate([0,size/2,0]) cube([size-(thickness*4),size*1.5,size+1], center=true);
			rotate([0,90,0])
			for(i = [(size/3)-thickness,-(size/3)+thickness])
				translate([i,0,0]) 
				rotate([90,0,0])
				cylinder(size*2, size/10, size/10);
		}
	}
}

module conn_female(size=23, thickness=1.5) {
	difference() {
		cube(size, center=true);
		conn_male(size, thickness=thickness, full=true);
		for(i = [size/4,-size/4])
			translate([i,0,0]) 
			rotate([90,0,0]) cylinder(size*2, size/10, size/10);
	}
}

module connector(size=10, thickness=1.5, gap=0.6, design=false) {
	if(!design) {
		//Print
		translate([0,size*1.5,-(thickness+gap/2)]) conn_male(size-gap,thickness);
		conn_female(size,thickness);
	} else {
		//Design
		conn_male(size-gap,thickness);
		% conn_female(size,thickness);
	}
}

//connector(design=true);
connector();