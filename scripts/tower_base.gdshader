shader_type canvas_item;
uniform float cut_y = -150.0;
uniform bool upper = true;
varying float local_y;
void vertex() { local_y = VERTEX.y; }
void fragment() {
 if ((upper && local_y >= cut_y) || (!upper && local_y < cut_y)) { discard; }
}
