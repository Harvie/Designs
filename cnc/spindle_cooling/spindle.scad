$fn = 100;

module fan() {
    hull() {
        for (a =[0,90,180,270]) rotate([0,0,a+22.5]) translate([16.1,16.1,0]) cylinder(60,4,4);
        }
}

module spindle() {
    cylinder(3,31,31);
    cylinder(7,25,25);
    //translate([0,0,37]) cube([40.2,40.4,60], center=true);
    fan();
    for (a =[0,90,180,270]) rotate([0,0,a]) translate([28.5,0,0]) cylinder(25,1.5,1.5);
    rotate([0,0,45]) translate([28,0,0]) cylinder(20,3,3);
    rotate([0,0,45]) translate([25,0,0]) cylinder(7,3,3);
}

module aviation_plug() {
    cylinder(9,11.5,11.5); //venek
    translate([0,0,-8]) cylinder(10,9.5,9.5); //prostup
    translate([0,0,-18]) cylinder(15,15,15); //matka
    hull() {
    translate([0,10,-29]) cylinder(26,15,15);
    translate([0,-10,-29]) cylinder(26,15,15);
    }
    translate([-10,10,-23]) cylinder(20,10,10);
}

module zaklad() {
    hull() {
    translate([0,0,2.999]) cylinder(21.9,31,31);
    //%rotate([0,0,22.5]) translate([20,0,14]) cube([40,62,21.9],center=true);
    rotate([0,0,22.5]) translate([35,0,2.999]) cylinder(21.9,31,31);
    }
}

module holder() {
    difference() {
        zaklad();
        spindle();
        //fan();
        rotate([0,0,22.5]) translate([45,0,25]) aviation_plug();
        }
    //rotate([0,90,22.5]) translate([-10,0,40]) aviation_plug();
        
}

//aviation_plug();
//fan();
//spindle();
//zaklad();
translate([30,0,0]) rotate([180,0,22]) translate([0,0,-24.9]) holder();