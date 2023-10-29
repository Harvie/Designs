//Model of infamous Beograd Rudo Buildings in Istočna Kapija Park (Serbia)

fast=false; //disable slow features like windows...

module rudo_module(xs=5, ys=4, zs=3, s=1, in=0.2, shrink=0)  {
	//jeden "blok" (patro) budovy
	
	inb=0.15;
	inx=0.5;
	
	lsx=xs-(shrink*2);
	lsy=ys-(shrink*2);
	lsz=zs;
	ssx=lsx-(in*2);
	ssy=lsy-(in*2);
	ssz=lsz;
	
	rr=3;
	rc=xs*ys*2;
	randx=rands(-1,xs,rc+1);
	randy=rands(-1,ys,rc+1);
	randz=rands(0.3,1.8,rc+1);

	translate([shrink,shrink,0]) difference() {
		//Zakladni tvar patra
		translate([-0.5,-0.5,-0.5]) cube([lsx,lsy,lsz]);
	
		//Nahodne otevrena okna
		if(!fast) difference() {
			for(i = [0 : rc]) {
				translate([
					round(randx[i]*rr)/rr,
					round(randy[i]*rr)/rr,
					round(randz[i]/2)*1.5
				]) cube([1,1,0.6], center=true);
			}
			
			//Kostka ktera limituje hloubku oken
			translate([in-0.5,in-0.5,-0.5]) cube([ssx,ssy,ssz]);
		}
	
		//celni sachty
		translate([inb-1,ys/2-0.5,0]) cube([1,1,zs*3], center=true);
		translate([xs-inb,ys/2-0.5,0]) cube([1,1,zs*3], center=true);
	
		//rohy
		if(shrink==0) {
			translate([-0.5,-0.5,0]) cube([2*inx,2*inx,zs*3], center=true);
			translate([-0.5,ys-0.5,0]) cube([2*inx,2*inx,zs*3], center=true);
			translate([xs-0.5,-0.5,0]) cube([2*inx,2*inx,zs*3], center=true);
			translate([xs-0.5,ys-0.5,0]) cube([2*inx,2*inx,zs*3], center=true);
		}
	}
}

module rudo_building() {
	w=6;
	translate([0,0.5-(w/2),0]) {
		//sklep
		translate([0,0,-2]) rudo_module(10,w,2, shrink=0.15, in=0.1);
		translate([11,0,-2]) rudo_module(4,w,2, shrink=0.15, in=0.1);
		//patra
		translate([0,0,0]) rudo_module(15,w,3);
		translate([0,0,3]) rudo_module(10,w,1, shrink=0.15);
		translate([0,0,4]) rudo_module(10,w,3);
		translate([0,0,7]) rudo_module(9,w,3);
		translate([0,0,10]) rudo_module(8,w,3);
		translate([0,0,13]) rudo_module(7,w,3);
		translate([0,0,16]) rudo_module(6,w,3);
		translate([1,0,19]) rudo_module(4,w,3);
		//vytahova budka
		translate([1.5,0,20]) cube([2,1.5,2]);
		translate([1.5,w-2.5,20]) cube([2,1.5,2]);
	}
}

module rudo_scene() {
	//vsechny 3 budovy
	for(r=[0,120,240]) rotate([0,0,r]) translate([7.5,0,2.5]) rudo_building();
	difference() {
		intersection() {
			translate([0,0,-77]) sphere(r=80, $fn=100);
			cylinder(r=16, h=3);
		}
		//napis
		rotate([0,0,30]) translate([-12.5,3,0.3])
		rotate([180,0,0]) linear_extrude(1) scale(0.5) text("HARVIE");
	}
}

//!translate([0,-1,0]) rudo_module(7,3,3, shrink=0.2)
//scale(2) rudo_building();

scale(2) rudo_scene();