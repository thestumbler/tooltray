include <lib.scad>


// makes a flat plate with quarter-rounded edges on the bottom
//
module make_cube_quarter_round( size ) {
  halfz = 0.5*size.z;
  // cube portion with rounded corners
  translate([0,0,1.5*halfz])
  minkowski() {
    cube([cap.x-2*halfz, cap.y-2*halfz, 0.5*halfz], center=true);
    cylinder(d=2*halfz,h=0.5*halfz, center=true);
  }
  // rounded edges end portion
  translate([0,0,halfz])
  union() {
    translate([0,0,-0.5*halfz])
      cube([size.x-2*halfz,size.y-2*halfz,halfz], center=true);
    difference() {
      for(angle=[0,90,180,270]) {
        rotate(angle,[0,0,1]) {
          if( angle==0 || angle==180) {
            translate([0.5*size.x-halfz,0.5*size.y-halfz,0])
              sphere(d=2*halfz);
            translate([0,0.5*size.y-halfz,0])
              rotate(90,[0,1,0])
                cylinder(d=2*halfz,h=size.x-2*halfz, center=true);
          } else {
            translate([0.5*size.y-halfz,0.5*size.x-halfz,0])
              sphere(d=2*halfz);
            translate([0,0.5*size.x-halfz,0])
              rotate(90,[0,1,0])
                cylinder(d=2*halfz,h=size.y-2*halfz, center=true);
          }
        }
      }
      translate([0,0,0.5*halfz])
        cube([size.x+1,size.y+1, halfz], center=true);
      cube([size.x-2*halfz,size.y-2*halfz,2*size.z], center=true);
    }
  }
}

module make_cube_quarter_round_old( size ) {
  union() {
    translate([0,0,-0.5*size.z])
      cube(size-[2*size.z,2*size.z,0], center=true);
    difference() {
      for(angle=[0,90,180,270]) {
        rotate(angle,[0,0,1]) {
          if( angle==0 || angle==180) {
            translate([0.5*size.x-size.z,0.5*size.y-size.z,0])
              sphere(d=2*size.z);
            translate([0,0.5*size.y-size.z,0])
              rotate(90,[0,1,0])
                cylinder(d=2*size.z,h=size.x-2*size.z, center=true);
          } else {
            translate([0.5*size.y-size.z,0.5*size.x-size.z,0])
              sphere(d=2*size.z);
            translate([0,0.5*size.x-size.z,0])
              rotate(90,[0,1,0])
                cylinder(d=2*size.z,h=size.y-2*size.z, center=true);
          }
        }
      }
      translate([0,0,0.5*size.z])
        cube(size+[1,1,0], center=true);
      cube(size-[2*size.z,2*size.z,-10], center=true);
    }
  }
}
module make_cube_quarter_round_1( size ) {
  halfz = 0.5*size.z;
  translate([0,0,-0.5*halfz])
    cube([size.x, size.y, halfz], center=true);
  translate([0,0,-halfz])
  union() {
    translate([-0.5*halfz,0,-0.5*halfz])
      cube([size.x-halfz,size.y,halfz], center=true);
    difference() {
      translate([0.5*size.x-halfz,0,0])
        rotate(90,[1,0,0])
          cylinder(d=2*halfz,h=size.y, center=true);
      translate([0,0,0.5*halfz])
        cube([size.x+1,size.y+1,halfz], center=true);
      cube([size.x-2*halfz,size.y-2*halfz,halfz-2], center=true);
    }
  }
}

//========================================================================
//=== Aluminum Extrusions
//========================================================================
ex2020 = [20,20, "2020.dxf", "ex2020", 0.38];
ex2040 = [20,40, "2040.dxf", "ex2040", 0.00]; // TODO mass
ex4020 = [40,20, "4020.dxf", "ex4020", 0.00]; // TODO mass
ex4040 = [40,40, "4040.dxf", "ex4040", 0.00]; // TODO mass
function ex_name(ex) = ex[3];
function ex_filename(ex) = ex[2];
color_panel = "Silver";
// extrusion mass is given by the manufacturer
// as kg / length.  Note: length is mm
function ex_mass(ex,l) = (l*ex[4]) / 1.0e3;

//-------
// Generates a piece of AL extrusion along the Z axis
//-------
module extrusion( ex, h ) {
  color(color_panel)
  linear_extrude(height=h)
    import(ex_filename(ex));
}



// panels made from D4-untrimmed Chinese poster board 
// standard size is 195 x 270 mm
// one sheet of cardboard is about 1.25 ~ 1.30 mm thick
// a sandwich of three measures ~3.8 mm
shelf = [195, 270, 3.8];
shelf_color = "darkgoldenrod";

m3_insert_dia = 5.0;

slider_length = 10.0;
s1 = [ 5.0, 3.6, slider_length ]; // central box
s2 = [ [0.0,0.0], [0.0, 3.6 ], [3.6, 3.6] ]; // triangular wings
s3 = [ [0.0,0.0], [0.0, 3.6], [-3.6, 3.6] ]; // triangular wings
s00 = [5.0, 5, slider_length ]; // bridge to shelf interface
s0 = [ 3.0, 15, slider_length ]; // interface with shelf
module make_slider() {
  difference() {
    union() {
      translate([-0.5*s00.x,0,0])
        cube(s00);
      translate([-0.5*s0.x+0.5*shelf.z+0.5*s0.x, 2, 0]) 
        cube(s0);
      translate([0.0, -3.6, 0.0]) {
        translate([-0.5*s1.x,0,0]) 
          cube(s1);
        translate([0.5*s1.x,0,0]) 
          linear_extrude(slider_length) 
            polygon(s2);
        translate([-0.5*s1.x,0,0]) 
          linear_extrude(slider_length) 
            polygon(s3);
      }
    }
    // m3 insert hole
    translate([10, 4+0.5*s0.y, 0.5*slider_length])
      rotate(-90,[0,1,0])
        cylinder(d=m3_insert_dia, h=2*s0.y);
    // chop off edges of wedges
    translate([4,-4,-1])
      #cube([5,5,2*slider_length],center=false);
    translate([-4-5,-4,-1])
      #cube([5,5,2*slider_length],center=false);
  }
}
module place_slider(offset) {
  translate([0,+0.5*ex.y-1.5,offset])
    make_slider();
}

cap = [ 20.0, 20.0, 2.0 ];
cap_peg_dia = 3.8;
cap_peg_hgt = 3;
cap_grip = [5.45, 1.5, 2];
cap_grasp = [8.3, 2, 2];
cap_color = "lightblue";
cap_notch = [5.5, 10, 10];
module make_endcap(shelf=false) {
  $fn=50;
  color(cap_color) 
  difference() {
    union() {
      // square cap
      // // cube portion
      // translate([0,0,-0.5*cap.z])
      // minkowski() {
      //   cube([cap.x-2*cap.z, cap.y-2*cap.z, 0.5*cap.z], center=true);
      //   cylinder(d=2*cap.z,h=0.5*cap.z, center=true);
      // }
      // // rounded edges end portion
      translate([0,0,-cap.z])
      make_cube_quarter_round(cap);

      // interlocking bits
      union() {
        // center peg
        cylinder(d=cap_peg_dia,h=cap_peg_hgt);
        // gripping protrusions
        for(angle=[0,90,180,270]) {
          if( !shelf || shelf && angle != 180 ) {
            rotate(angle,[0,0,1]) {
              translate([0, -0.5*cap.y+0.5*cap_grip.y,0.5*cap_grip.z])
                cube(cap_grip, center=true);
              translate([0, -0.5*cap.y+cap_grip.y+0.5*cap_grasp.y,0.5*cap_grasp.z])
                cube(cap_grasp, center=true);
            }
          }
        }
      } // interlocking bits
    } // union
    if(shelf) {
      translate([0, 0.5*cap.y, 0]) // +0.5*cap_notch.y,0.5*cap_notch.z])
        cube(cap_notch, center=true);
    }
  } // difference
}
module place_endcap(offset=0, shelf=false) {
  if(offset==0.0) {
    make_endcap(shelf);
  } else {
  translate([0,0,offset])
    rotate(180,[0,0,1])
    rotate(180,[1,0,0])
      make_endcap(shelf);
  }
}
module print_endcap() {
  translate([0,0,cap.z])
    make_endcap();
}

// makes an endcap with a support to attach the shelf
supt_len = 30; // protrusion length from center of extrusion
pem_thk = 6;
supt = [ 0.5*(cap.x-cap_notch.x), supt_len, cap.z ];
pem = [ supt.x, supt_len - 0.5*cap.x-2, pem_thk ];
module make_endcap_with_support(offset=0) {
  color(cap_color)
  difference() {
    union() {
      difference() {
        make_endcap(true);
        // chop off the edge we will be extending...
        translate([0.5+0.5*cap.x-0.5*supt.x, 0.5*cap.y+0.0*supt.y-0.5, -0.5-0.5*supt.z])
          cube([2+supt.x, 2*supt.z, 2+2*supt.z], center=true);
      }
      translate([0.5*cap.x-0.5*supt.x, 0.5*supt.y, 0])
        make_cube_quarter_round_1( supt );
      translate([0.5*cap_notch.x, 2+0.5*cap.y, 0])
        cube(pem);
    }
    translate([0.5,supt_len-0.5*pem.y, -cap.z + 0.5*(pem.z+cap.z)])
      rotate(90,[0,1,0])
        cylinder(d=m3_insert_dia, h=2+pem.x+2*cap.z);
  }

}
module place_endcap_with_support(offset=0, mirror=false) {
  if(offset==0.0 && !mirror) {
    make_endcap_with_support();
  } else {
    translate([0,0,offset])
      rotate(180,[0,0,1])
        rotate(180,[1,0,0])
        mirror([1,0,0])
          make_endcap_with_support();
  }
}
module print_endcap_with_support() {
  translate([0,0,cap.z])
    make_endcap_with_support();
}
module print_endcap_with_support_pair() {
  translate([0.0*cap.x,-supt_len+0.5*pem.y,cap.z])
    make_endcap_with_support();
  translate([-0.5*cap.x,supt_len-0.5*pem.y,cap.z])
    rotate(180,[0,0,1])
        mirror([1,0,0])
    make_endcap_with_support();
}
module print_endcap_with_support_pair_a() {
  gap=2;
  translate([0,+0.5*cap.x+0.5*gap,cap.z])
    rotate(90,[0,0,1])
    make_endcap_with_support();
  translate([0,-0.5*cap.x-0.5*gap,cap.z])
    rotate(-90,[0,0,1])
    rotate(180,[0,0,1])
        mirror([1,0,0])
    make_endcap_with_support();
}
module print_endcap_with_support_pair_b() {
  gap=2;
  translate([0,+0.5*cap.x+0.5*gap,cap.z])
   rotate(-90,[0,0,1])
    make_endcap_with_support();
  translate([0,-0.5*cap.x-0.5*gap,cap.z])
    rotate(90,[0,0,1])
    rotate(180,[0,0,1])
        mirror([1,0,0])
    make_endcap_with_support();
}
module print_endcap_with_support_quad() {
  translate([supt_len-0.5*pem.y,0,0])
    print_endcap_with_support_pair_a();
  translate([-supt_len+0.5*pem.y,0,0])
    print_endcap_with_support_pair_b();
}

//========================================================================
//=== Simple Utility Functions
//========================================================================

// calculates the volume in m^3, 
// note that the inputs are in mm
function volume(a) = a.x*a.y*a.z / 1.0e9;

// calculates mass using volumen (m^3) 
// and density, kg / m^3
function mass(a,d) = d*volume(a);

// calculates the perimeter, 
// used to estimate gasket material qty
function perimeter(a) = a.x+a.x+a.y+a.y;

// calculates the area in m^2, 
// note that the inputs are in mm
function area(a) = a.x*a.y / 1.0e6;

module rounded_tube( length, dia ) {
  translate([0,0,0.5*dia]) {
    sphere(d=dia);
    cylinder( h=length-dia, d=dia, center=false);
    translate([0,0,length-dia]) sphere(d=dia);
  }
}

//========================================================================
//=== Makes a "ghost" cube, useful for checking things
//========================================================================
ghost_dia=3;
ghost_color="GreenYellow";
ghost_alpha=0.25;
ghost_border="Black";
module make_ghost_simple( size, ctr ) {
  %cube([size.x,size.y,size.z], center=ctr);
}

module make_ghost( size, ctr ) {
  color(ghost_color, ghost_alpha) 
    translate(0.5*[gasket_dia,gasket_dia,gasket_dia])
    cube(size-[gasket_dia,gasket_dia,gasket_dia], center=ctr);
    //cube([size.x,size.y,size.z], center=ctr);

  color(ghost_border) {
    translate([0.5*ghost_dia,0.5*ghost_dia,0])
    rounded_tube(size.z, ghost_dia);
    translate([0.5*ghost_dia,size.y-0.5*ghost_dia,0])
      rounded_tube(size.z, ghost_dia);
    translate([size.x-0.5*ghost_dia,+0.5*ghost_dia,0])
      rounded_tube(size.z, ghost_dia);
    translate([size.x-0.5*ghost_dia,size.y-0.5*ghost_dia,0])
      rounded_tube(size.z, ghost_dia);

    translate([0,0.5*ghost_dia,0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([0.5*ghost_dia,0,0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);

    translate([0,size.y-0.5*ghost_dia,0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([size.x-0.5*ghost_dia,0,0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);


    translate([0,0.5*ghost_dia,size.z-0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([0.5*ghost_dia,0,size.z-0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);

    translate([0,size.y-0.5*ghost_dia,size.z-0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([size.x-0.5*ghost_dia,0,size.z-0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);

  }

}


//========================================================================
//=== Generate flat 2D corner joiner plates
//========================================================================
// Using corner brackets from user mightynozzle
// https://www.thingiverse.com/thing:2503622
// https://mightynozzle.com
color_corner = "Purple";

module flat_2d_corner(adj="") {
  mkbom(str("corner", adj, TAB, 5)); // number of screws per corner, M5
  aluminium_extrusion_bracket(
    shape = "L", type = "uniform", 
    bracket_height_in_millimeter = 7.0,
    support = "full", preview_color = color_corner
  );
}

// tool-tray opening in lab shelves
// 18 x 58, 35 deep
opening = [ 580, 350, 180 ];
module tool_tray_opening() {
  #cube( opening );
}



shelf_overlap = 4;
ex = ex2020;
function shelf_assy_wid()=2*ex.x+shelf.x-2*shelf_overlap;
// pre-cut lengths of extrusion
ex1 = 300; // shelf supports
ex3 = 170; // columns
// ex2 = 500; // front edge
ex2 = 3*ex.x+2*shelf_assy_wid();
echo(ex2);


module place_shelf(off=[0,0,0]) {
  translate([0,ex.x-shelf_overlap,0]) {
    color(shelf_color)
    translate(off) {
      translate([0,0,-0.5*shelf.z])
      cube(shelf);
    }
    // front lip extrusion
    translate([-ex.x+shelf_overlap,-0.5*ex.x+shelf_overlap,0])
      rotate(90,[0,1,0]) {
          // overlaping vertical posts
          // extrusion( ex, shelf.x+2*ex.x-2*shelf_overlap );
          // inside vertical posts
          length = shelf_assy_wid()-2*ex.x;
          translate([0, 0, ex.x]) {
            place_endcap(0,true);
            place_endcap(length,true);
            color("lightsteelblue")
              extrusion( ex, length );
          }
      }
  }
}

module place_shelf_assy(off=[0,0,0]) {
  // place the rails
  offsets=[0.0, shelf.x+ex.x-2*shelf_overlap];
  for( xoff=offsets ) {
    translate([xoff,0,0]) {
      rotate(-90,[1,0,0]) extrusion( ex, ex1 );
    }
  }
  // place the shelf
  translate([0.5*ex.x-shelf_overlap, 0, 0]) place_shelf();
}

shelf_posns = [ ex.x, 2*ex.x+shelf_assy_wid() ];
column_posns = [ 0.0, ex.x+shelf_assy_wid(), 2*ex.x+2*shelf_assy_wid() ];
// define number of shelfs and their vertical positions
shelf_heights = [ 0, 35, 75, 105, 140 ];

module make_tool_tray() {
  for( zoff=shelf_heights ) {
  for( xoff=shelf_posns ) {
    translate([xoff+0.5*ex.x, 0, zoff+0.5*ex.y])
      place_shelf_assy();
  }
  }
  // vertical supports
  for( xoff=column_posns ) {
    for( yoff=[0.0, shelf.y] ) {
      // 2020 profiles
      translate([xoff+0.5*ex.x, yoff+0.5*ex.y, 0]) extrusion( ex2020, ex3 );
      // 2040 profiles
      // translate([xoff+0.5*ex2040.x, yoff+0.0*ex2040.y+shelf_overlap, 0])  {
      //   extrusion( ex2040, ex3 );
      // }
    }
  }
  // front piece
  translate([0, 0.5*ex.x, -0.5*ex.y])
    rotate(90,[0,1,0])
      extrusion( ex, ex2 );
}

make_tool_tray();
*tool_tray_opening();

*place_shelf();

// place_slider(10);
// make_slider();

// make_endcap();
// make_endcap_with_support();
// extrusion( ex, 10 );
// place_endcap(10);

// extrusion( ex, 25 );
// place_endcap_with_support();
// place_endcap_with_support(25);
// place_endcap_with_support(mirror=true);

// print_endcap();
// print_endcap_with_support();
// print_endcap_with_support_pair();
// print_endcap_with_support_quad();

// make_cube_quarter_round([cap.x, cap.y,2]);
// translate([11,0,0.25]) cube([1,1,0.5], center=true);
// translate([13,0,0.5]) cube([1,1,1], center=true);
// translate([15,0,1.0]) cube([1,1,2], center=true);
