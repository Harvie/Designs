translate([40,0,0]) difference() {
cube([30,20,10]);
translate([15,10,10]) rotate([90,0]) cylinder(15,5,5);
    translate([5,10,-5]) cylinder(20,2,2);
    translate([25,10,-5]) cylinder(20,2,2);
}

translate([40,-30,0]) difference() {
cube([30,20,10]);
translate([15,10,10]) rotate([90,0]) cylinder(15,5,5);
    translate([5,10,-5]) cylinder(20,2,2);
    translate([25,10,-5]) cylinder(20,2,2);
}

difference() {
cube([30,20,10]);
translate([-1,5,5]) cube([40,10,7]);
    translate([5,10,-5]) cylinder(20,2,2);
    translate([25,10,-5]) cylinder(20,2,2);
}