shader_type canvas_item;
uniform vec2 cover_min;
uniform vec2 cover_max;
varying vec2 world_pixel;
void vertex() {
 world_pixel = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}
void fragment() {
 if (world_pixel.x >= cover_min.x && world_pixel.x < cover_max.x && world_pixel.y >= cover_min.y && world_pixel.y < cover_max.y) {
  COLOR.a = 0.0;
 }
}
