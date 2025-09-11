shader_type spatial;

uniform float size;
uniform float speed;
uniform vec3 color : source_color;

uniform float segment_length = 25.0;
uniform float spacing = -.6;

void fragment() {
	ALBEDO = color;
	if (sin(size*UV.y*segment_length-speed*TIME) < spacing) {
		discard;
	}
}