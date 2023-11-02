//sine_thread.scad by Ron Butcher (aka. Ming of Mongo), 
//with bits borrowed from ISOThread by Trevor Moseley
//
//Thread libs for OpenSCAD are hideously slow.  I love OpenSCAD, but that's the fact.
//But I found that, if you are cool with approximating iso threads with a sine wave,
//you can make very smooth threads really fast just by spinning a circle around.
//
//Actually, you could make near perfect threads by specifying a polygon other than a circle
//with the exact screw cross-section you need, but I leave that as an excersize for those
//who care more than I do.  Circle works for me.
//
//threads module gives a threaded rod
//hex_nut(diameter) does just what you think
//hex_screw(diameter, length) gives an M(diameter) hex head screw with length mm of thread.
//
//defaults get you an M4 x 10mm bolt and an M4 nut.  If you want something non standard,
//you can supply the pitch, head height and diameter, rez(olution) and a scaling factor
//to help make up for the oddities of everyone's individual printers and settings.
//
//Finer layering gets you better results.  At .1mm layer height, my M4 threads kick ass.
//
//This is all metric, but you can translate US diameters and pitch to mm easily enough.


module threads(diameter=4,pitch=undef,length=10,scale=1,rez=20){
	pitch = (pitch!=undef) ? pitch : get_coarse_pitch(diameter);
	twist = length/pitch*360;
	depth=pitch*.6;
	linear_extrude(height = length, center = false, convexity = 10, twist = -twist, $fn = rez)
		translate([depth/2, 0, 0]){
			circle(r = scale*diameter/2-depth/2);
		}
}	

module hex_nut(	diameter = 4,
				height = undef, 
				span = undef,  
				pitch = undef, 
				scale = 1, 
				rez = 20){
	height = (height!=undef) ? height : hex_nut_hi(diameter);
	span = (span!=undef) ? span : hex_nut_dia(diameter);
	
	difference(){
		cylinder(h=height,r=span/2, $fn=6); //six sided cylinder
		threads(diameter,pitch,height,scale,rez);
		cylinder(h=diameter/2, r1=diameter/2, r2=0, $fn=rez);
			translate([0,0,height+.0001])
		rotate([180,0,0])
				#cylinder(h=diameter/2, r1=diameter/2, r2=0, $fn=rez);
	}
}

module hex_screw(diameter = 4, 
				length = 10, 
				height = undef, 
				span = undef, 
				pitch = undef, 
				scale = 1, 
				rez = 20){
	height = (height!=undef) ? height : hex_bolt_hi(diameter);
	span = (span!=undef) ? span : hex_bolt_dia(diameter);
	cylinder(h=height,r=span/2,$fn=6); //six sided cylinder
	translate([0,0,height])
		threads(diameter,pitch,length,scale,rez);
}

// Lookups shamelessly stolen from ISOThread.scad by Trevor Moseley
// function for thread pitch
function get_coarse_pitch(dia) = lookup(dia, [
[1,0.25],[1.2,0.25],[1.4,0.3],[1.6,0.35],[1.8,0.35],[2,0.4],[2.5,0.45],[3,0.5],[3.5,0.6],[4,0.7],[5,0.8],[6,1],[7,1],[8,1.25],[10,1.5],[12,1.75],[14,2],[16,2],[18,2.5],[20,2.5],[22,2.5],[24,3],[27,3],[30,3.5],[33,3.5],[36,4],[39,4],[42,4.5],[45,4.5],[48,5],[52,5],[56,5.5],[60,5.5],[64,6],[78,5]]);

// function for hex nut diameter from thread size
function hex_nut_dia(dia) = lookup(dia, [
[3,6.4],[4,8.1],[5,9.2],[6,11.5],[8,16.0],[10,19.6],[12,22.1],[16,27.7],[20,34.6],[24,41.6],[30,53.1],[36,63.5]]);
// function for hex nut height from thread size
function hex_nut_hi(dia) = lookup(dia, [
[3,2.4],[4,3.2],[5,4],[6,3],[8,5],[10,5],[12,10],[16,13],[20,16],[24,19],[30,24],[36,29]]);


// function for hex bolt head diameter from thread size
function hex_bolt_dia(dia) = lookup(dia, [
[3,6.4],[4,8.1],[5,9.2],[6,11.5],[8,14.0],[10,16],[12,22.1],[16,27.7],[20,34.6],[24,41.6],[30,53.1],[36,63.5]]);
// function for hex bolt head height from thread size
function hex_bolt_hi(dia) = lookup(dia, [
[3,2.4],[4,3.2],[5,4],[6,3.5],[8,4.5],[10,5],[12,10],[16,13],[20,16],[24,19],[30,24],[36,29]]);

wrench_ratio = 1.1547;
wrench = wrench_ratio * 13;

difference() {
	union() {
		//european shower head thread
		threads(diameter=20, pitch=2, length=10, rez=60);
		hull() {
		cylinder(d1=wrench, d2=wrench, h=15, $fn=6);
		translate([0,0,20]) sphere(d=6, $fn=32);
		}
	}
	translate([0,0,-10]) cylinder(d=1, h=100, $fn=32);
	translate([0,0,-0.1]) cylinder(d1=4, d2=1, h=10, $fn=32);
}

//translate([18.8,0,0.5])
//import("/home/harvie/Downloads/nasadka_na_dysh_2_mm_v1.stl");