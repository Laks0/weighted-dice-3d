shader_type canvas_item;

uniform float fishEyeAmount = 0.0;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05; // Adjust the amount of grain
uniform float grain_size : hint_range(0.1, 10.0) = 1.0; // Adjust the size of the grain

void fragment() {
	float newAmount = (fishEyeAmount / 100.0) + 1.0;

	vec2 texcoord0 = UV;
	vec2 kCenter = vec2(0.5);

	vec2 vec = (texcoord0 - kCenter) / kCenter;
	float vecLength = length(vec);
	float r = pow(min(vecLength, 1.0), newAmount) * max(1.0, vecLength);
	vec2 unit = vec / vecLength;

	texcoord0 = kCenter + r * unit * kCenter;

	// Sample the original screen texture
    vec4 original_color = texture(TEXTURE, texcoord0);

    // Generate random noise
    float noise = (fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;

    // Add noise to the original color
    original_color.rgb += noise * grain_amount * grain_size;

    // Clamp the final color to make sure it stays in the valid range
    COLOR = clamp(original_color, 0.0, 1.0);
}