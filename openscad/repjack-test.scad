module pagoda(scale=1, height=1, ratio=2, center=true) {
	scale([scale,scale])
	linear_extrude(height=height, center=center)
	polygon(points=[[-1,1],[1,1],[1*ratio,-1],[-1*ratio,-1]], paths=[[0,1,2,3]]);
}

module female(thickness=0.3) {
	difference() {
		%cube([4,2+thickness,1+(2*thickness)], center=true);
		translate([0,thickness,0]) pagoda(ratio=1.5);
	}
}

module male() {
	difference() {
		pagoda(ratio=2, scale=0.9);		
		//translate([0,-0.7]) pagoda(ratio=2);
		translate([0,-0.21]) pagoda(ratio=2, scale=0.7, height=1.1);
	}
}

module connector(design=false) {
	scale(4) if(!design) {
		//Print
		translate([0,3,0-1.15+0.5]) male();
		rotate([90]) female();
	} else {
		//Design
		male();
		% female();
	}
}

//connector(design=true);
connector();
