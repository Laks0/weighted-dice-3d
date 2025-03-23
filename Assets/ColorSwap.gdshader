shader_type spatial;
render_mode depth_prepass_alpha;

uniform sampler2D spriteTexture: source_color, filter_nearest;
uniform sampler2D palette: source_color, filter_nearest;
uniform float rows;
uniform float columns;
uniform float swap_from;
uniform float swap_to;

void fragment() {
	ALBEDO = texture(spriteTexture, UV).rbg;
	ALPHA = texture(spriteTexture, UV).a*.9;
	float from_row_u = (swap_from+.5) / rows;
	float to_row_u = (swap_to+.5) / rows;
	for (float col = 0.0; col < columns; col++) {
		float col_v = (col+.5) / columns;
		vec2 from_sample_UV = vec2(from_row_u, col_v);
		vec2 to_sample_UV = vec2(to_row_u, col_v);
		vec3 from_sample_color = texture(palette, from_sample_UV).rgb;
		if (distance(ALBEDO, from_sample_color) < .2) {
			ALBEDO = texture(palette, to_sample_UV).rgb;
			break;
		}
	}
}