shader_type canvas_item;
uniform float cut_y = -150.0;
uniform bool upper = true;
uniform bool gold_banner = false;
varying float local_y;
void vertex() { local_y = VERTEX.y; }
void fragment() {
 vec4 tex = texture(TEXTURE, UV);
 // Only the central blue cloth; preserve the original gold emblem and trim.
 if (gold_banner && UV.x > 0.39 && UV.x < 0.61 && UV.y > 0.68 && UV.y < 0.92 && tex.b > tex.r * 1.4 && tex.b > tex.g * 1.15) {
  float light = max(tex.r, max(tex.g,tex.b));
  COLOR = vec4(mix(vec3(0.48,0.25,0.045),vec3(1.0,0.82,0.29),light),tex.a);
 }

 if ((upper && local_y >= cut_y) || (!upper && local_y < cut_y)) { discard; }
}
