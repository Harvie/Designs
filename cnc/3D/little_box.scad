$fn=100;

module bottom(dia=15) {
difference() {
union() {
cylinder(20, dia+4, dia+4);
cylinder(15, dia+8, dia+8);
}
translate([0,0,3]) cylinder(21, dia, dia);
}
}

module top(dia=15) {
difference() {
cylinder(20, dia+8, dia+8);
translate([0,0,3]) cylinder(21, dia, dia);
translate([0,0,15]) cylinder(6, dia+4, dia+4);
}
}

translate([-60,0,0]) bottom();
top();