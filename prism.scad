/*
 * Creates a prism
 */
module prism(v,h){
  linear_extrude(height=h,slices=1)
  polygon(v);
}

prism([[0,0],[10,0],[0,20]],10);
