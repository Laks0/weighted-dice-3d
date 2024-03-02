shader_type spatial;

uniform float size = 64.0;
uniform vec4 color : source_color;
uniform sampler2D screenTexture;
uniform vec2 ratio;

void fragment() {
	vec2 pixelated_uv = floor(UV * size * ratio) / (size * ratio);
	float dots = length(fract(UV * size * ratio) - vec2(.5)) * 2.0;
	dots = (1.0 - dots) * 10.0;
	dots = clamp(dots, 0.0, 1.0);
	ALBEDO = mix(color, texture(screenTexture, pixelated_uv), dots).rgb;
}