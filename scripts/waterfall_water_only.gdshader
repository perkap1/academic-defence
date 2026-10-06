shader_type canvas_item;
render_mode unshaded;

// Keep the existing banks and silhouette fixed; animate water only.
uniform sampler2D map_texture : filter_nearest, repeat_disable;
uniform vec2 map_origin = vec2(0.0);
uniform vec2 map_x_axis = vec2(1.0, 0.0);
uniform vec2 map_y_axis = vec2(0.0, 1.0);
varying vec2 frame_position;

void vertex() {
 frame_position = VERTEX;
}

bool is_water(vec3 pixel) {
 bool blue = pixel.b > pixel.r * 1.15 && pixel.g > pixel.r * 1.12 && pixel.b > 0.3;
 bool foam = pixel.r > 0.68 && pixel.g > 0.75 && pixel.b > 0.75 && pixel.b >= pixel.r * 0.94;
 return blue || foam;
}

void fragment() {
 vec2 map_pixel = floor(map_origin + frame_position.x * map_x_axis + frame_position.y * map_y_axis) + vec2(0.5);
 vec4 background = texture(map_texture, map_pixel / vec2(textureSize(map_texture, 0)));
 vec4 animated = texture(TEXTURE, UV);
 float overlay = (is_water(background.rgb) && is_water(animated.rgb)) ? animated.a : 0.0;
 COLOR = vec4(animated.rgb, overlay);
}

