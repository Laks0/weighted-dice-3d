shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);

	COLOR.a *= smoothstep(.0, .2, UV.x) * smoothstep(.0, .2, 1.0 - UV.x);
}