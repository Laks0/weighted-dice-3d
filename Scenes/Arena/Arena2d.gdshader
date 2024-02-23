shader_type canvas_item;

uniform sampler2D fullTexture;
uniform sampler2D lowTexture;
uniform float pixelateThreshold;

void fragment() {
	float alpha = COLOR.a;
	vec4 fullColor = texture(fullTexture, UV).rgba;
	vec4 lowColor = texture(lowTexture, UV).rgba;
	
	if (distance(fullColor, lowColor) > pixelateThreshold) {
		if (alpha == 1.0) {
			COLOR = fullColor;
		}
	} else {
		COLOR.a = .0;
	}
}
