shader_type canvas_item;
render_mode unshaded;

uniform sampler2D fullTexture;
uniform sampler2D lowTexture;

void fragment() {
	float alpha = COLOR.a;
	vec4 fullColor = texture(fullTexture, UV).rgba;
	vec4 lowColor = texture(lowTexture, UV).rgba;
	
	if (fullColor != lowColor) {
		if (alpha == 1.0) {
			COLOR = fullColor;
		}
	} else {
		COLOR.a = .0;
	}
}
