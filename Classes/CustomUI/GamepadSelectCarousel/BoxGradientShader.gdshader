shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);

	COLOR.a *= smoothstep(.0, .4, UV.x) * smoothstep(.0, .4, 1.0 - UV.x);
}