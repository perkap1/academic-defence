shader_type canvas_item;
uniform bool boss=false;
uniform int kind=0;
uniform int facing=0;
uniform bool flipped=false;
uniform vec4 clothes;
uniform vec2 actor_origin;
uniform float actor_scale=0.7;
uniform bool clip_bridge=false;
uniform vec2 cover_min;
uniform vec2 cover_max;
varying vec2 world_pixel;
void vertex(){world_pixel=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).xy;}
void fragment(){
 vec4 tex=texture(TEXTURE,UV);
 vec3 c=tex.rgb;
 vec2 p=(world_pixel-actor_origin)/actor_scale;
 bool region=p.x>=clothes.x && p.y>=clothes.y && p.x<=clothes.z && p.y<=clothes.w;
 bool blue=c.b>c.r*1.14 && c.b>c.g*0.98 && c.b>0.15;
 bool green=c.g>c.r*1.13 && c.g>c.b*1.10 && c.g>0.12;
 bool red=c.r>c.g*1.7 && c.r>c.b*1.4 && c.g<0.24 && c.b<0.25;
 float brightest=max(c.r,max(c.g,c.b));
 float darkest=min(c.r,min(c.g,c.b));
 bool white=brightest-darkest<0.13 && darkest>0.6;
 bool cloth=kind==2 ? green || white : (kind==3 ? blue : (kind==4 ? blue || red || green : (kind==5 ? blue || red : blue || white || red)));
 // The book stack sits in front of the vest/sleeves, and must keep its colors.
 float side_x=flipped ? -p.x : p.x;
 if(kind==2 && ((facing==0 && abs(p.x)<22.0) || (facing==1 && side_x<-6.0 && p.y<-12.0)))cloth=false;
 if(region && cloth && tex.a>0.1){
  float shade=dot(c,vec3(0.299,0.587,0.114));
  vec3 palette=boss ? vec3(0.115,0.095,0.15) : vec3(0.92,0.055,0.11);
  COLOR.rgb=palette*(0.35+shade*0.85)*(COLOR.rgb/max(c,vec3(0.001)));
 }
 if(clip_bridge && world_pixel.x>=cover_min.x && world_pixel.x<cover_max.x && world_pixel.y>=cover_min.y && world_pixel.y<cover_max.y)COLOR.a=0.0;
}
