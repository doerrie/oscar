/*
    base[3] = length,width,thickness of base
    arch[3] = height,width,thickness of arch
    gap[2]  = height,width of gap
    offset  = distance to move arch

    constraints:
    arch[1] <= base[1], the arch must fit the base
    gap[x] < arch[x], the gap must fit the arch
*/

module frame (base,arch,gap,offset) {
  union() {
    cube(base);
    translate([offset,(base[1]-arch[1])/2,base[2]])
      difference(){
        cube([arch[2],arch[1],arch[0]]);
        translate([-1,(arch[1]-gap[1])/2,-1])
        cube([arch[2]+2,gap[1],gap[0]+1]);
      }
  }
}

frame([300,250,6.75],[228.2,253.2,6.75], [203.2,203.2],100);
