shader_type canvas_item;

uniform sampler2D fullTexture;
uniform sampler2D lowTexture;

void fragment() {
	float alpha = COLOR.a;
	vec4 fullColor = texture(fullTexture, UV).rgba;
	vec4 lowColor = texture(lowTexture, UV).rgba;
	if (fullColor != lowColor) {
		COLOR = fullColor;
		COLOR.a = alpha;
	} else {
		COLOR.a = .0;
	}
}
