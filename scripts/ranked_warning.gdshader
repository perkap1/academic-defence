shader_type canvas_item;
void fragment(){
 vec4 c=texture(TEXTURE,UV);
 if(c.r>c.g*1.5 && c.r>c.b*1.3 && c.r>0.15){
  float shade=dot(c.rgb,vec3(0.299,0.587,0.114));
  COLOR.rgb=vec3(0.48,0.025,0.065)*(0.35+shade);
 }
}
