$fn=50;
height = 15;

difference() {
hull(){
cylinder(height,17.5,17.5);
translate([45.8,0,0]) cylinder(height,17.5,17.5);
}
cylinder(height,13.5,13.5);
translate([45.8,0,0]) cylinder(height,13.5,13.5);

translate([16.5,-13.1,0]) cube([13,26.2, height]);
}

translate([-5,0,0]) difference() {
hull(){

translate([45.8,31,0]) cylinder(height,17.5,17.5);
}
translate([45.8,31,0]) cylinder(height,13.5,13.5);
translate([7,5,0]) rotate([0,0,15]) cube([40,40, 40]);
}

