/*
 * face[3] = [length,width,thickness] of the face
 * back[2] = [length,thickness] of the back (width taken from face)
 * plate_offset[2] = [x_offset,y_offset] of the face hole, from the face center
 * plate_hole = diameter of face hole
 * motor_bolt_offset[2] = [x_offset,y_offset] of motor bolt hole from plate hole
 * motor_bolt_hole = diameter of motor bolt hole
 * rod_offset[2] =[x_offset,y_offset] of the rod, from the plate center
 * rod[4] = [outer_h,outer_d,inner_d,inner_pad, offset] of rod supp-ort
 */

use <prism.scad>;

module z_stepper_housing(face,back,plate_offset,plate_hole,motor_bolt_offset,motor_bolt_hole,rod_offset,rod,supp){
  difference(){
    union(){
      // block
      // move the block so the origin is at the motor hole
        plate_offset_z=face[1]/2+plate_offset[1];
      translate([0,plate_offset[0],-plate_offset_z])
        union(){
          // back
          translate([-back[0]/2,-face[0]/2,-back[1]])
          cube([back[0],face[0],back[1]]);
          // face
          translate([-face[2]/2,-face[0]/2,0])
          cube([face[2],face[0],face[1]]);
          // top-right-support
          translate([0,(supp-face[0])/2,0]) //shift
          rotate(a=90,v=[1,0,0]) //rotate
          translate([0,0,-supp/2]) //center
          prism([[face[2]/2,0],[back[0]/2,0],[face[2]/2,back[0]/2]],supp);
          // top-left-support
          translate([0,-(supp-face[0])/2,0]) //shift
          rotate(a=90,v=[1,0,0]) //rotate
          translate([0,0,-supp/2]) //center
          prism([[face[2]/2,0],[back[0]/2,0],[face[2]/2,back[0]/2]],supp);
          // bot-right-support
          translate([0,(supp-face[0])/2,0]) //shift
          rotate(a=180,v=[0,1,0])
          rotate(a=-90,v=[1,0,0]) //rotate
          translate([0,0,-supp/2]) //center
          prism([[face[2]/2,0],[back[0]/2,0],[face[2]/2,back[0]/2]],supp);
          // bot-left-support
          translate([0,-(supp-face[0])/2,0]) //shift
          rotate(a=180,v=[0,1,0])
          rotate(a=-90,v=[1,0,0]) //rotate
          translate([0,0,-supp/2]) //center
          prism([[face[2]/2,0],[back[0]/2,0],[face[2]/2,back[0]/2]],supp);
        }
      // linear rod mount
      translate([-rod[0]/2,rod_offset[0],-rod_offset[1]])
      rotate(a=90,v=[0,1,0])
      cylinder(h=rod[0],r=rod[1],$fn=30);
      // linear rod support
      translate([-rod[0]/2,rod[1]+rod_offset[0]/2,-rod_offset[1]])
      rotate(a=90,v=[0,1,0])
      cube([plate_offset_z,rod[1]*2,rod[0]]);
    }
    // remove the linear rod hole
    translate([rod[3]-rod[0]/2,rod_offset[0],-rod_offset[1]])
    rotate(a=90,v=[0,1,0])
    cylinder(h=rod[0]-rod[3]+1,r=rod[2],$fn=30);

    // the plate_hole
    translate([-face[2]/2-1,0,0])
    rotate(a=90,v=[0,1,0])
    cylinder(h=face[2]+2,r=plate_hole,$fn=30);

    // create all 4 motor motor_bolt holes
    _motor_bolt_hole(face[2],motor_bolt_hole, motor_bolt_offset);
    _motor_bolt_hole(face[2],motor_bolt_hole, [-1*motor_bolt_offset[0], motor_bolt_offset[1]]);
    _motor_bolt_hole(face[2],motor_bolt_hole, [motor_bolt_offset[0], -1*motor_bolt_offset[1]]);
    _motor_bolt_hole(face[2],motor_bolt_hole, [-1*motor_bolt_offset[0], -1*motor_bolt_offset[1]]);
  }
}

module _motor_bolt_hole(depth, radius, offset){
  translate([-depth/2-1,offset[0],offset[1]])
  rotate(a=90,v=[0,1,0])
  cylinder(h=depth+2,r=radius,$fn=30);
}

z_stepper_housing([30,10,2],[20,2],[3,0],3,[3.5,3.5],0.5,[8,0],[10,2,1,1],2);
