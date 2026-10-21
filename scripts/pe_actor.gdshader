shader_type canvas_item;
uniform vec2 outline[16];
uniform int point_count=4;
uniform bool flipped=false;
varying vec2 local_point;
void vertex(){local_point=vec2(flipped ? -VERTEX.x : VERTEX.x,VERTEX.y);}
void fragment(){
 bool inside=false;
 int previous=point_count-1;
 for(int i=0;i<16;i++){
  if(i<point_count){
   vec2 a=outline[i];vec2 b=outline[previous];
   if((a.y>local_point.y)!=(b.y>local_point.y)){
    if(local_point.x<(b.x-a.x)*(local_point.y-a.y)/(b.y-a.y)+a.x){inside=!inside;}
   }
   previous=i;
  }
 }
 if(!inside){discard;}
}
