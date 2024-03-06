shader_type spatial;
render_mode depth_prepass_alpha;

uniform sampler2D spriteTexture: source_color, filter_nearest;

uniform float borderAlpha : hint_range(0.0, 1.0);
uniform float width : hint_range(0.0, 16.0);
uniform vec4 outline_color : source_color;
uniform vec4 modulate : source_color;
 
void fragment()
{
    vec2 size = vec2(width) / vec2(textureSize(spriteTexture, 0));
   
    vec4 sprite_color = texture(spriteTexture, UV);
   
    float alpha = sprite_color.a;
    alpha += texture(spriteTexture, UV + vec2(0.0, -size.y)).a;
    alpha += texture(spriteTexture, UV + vec2(size.x, -size.y)).a;
    alpha += texture(spriteTexture, UV + vec2(size.x, 0.0)).a;
    alpha += texture(spriteTexture, UV + vec2(size.x, size.y)).a;
    alpha += texture(spriteTexture, UV + vec2(0.0, size.y)).a;
    alpha += texture(spriteTexture, UV + vec2(-size.x, size.y)).a;
    alpha += texture(spriteTexture, UV + vec2(-size.x, 0.0)).a;
    alpha += texture(spriteTexture, UV + vec2(-size.x, -size.y)).a;
   
    vec3 final_color = mix(outline_color.rgb, sprite_color.rgb, sprite_color.a);
    vec4 color = vec4(final_color, clamp(alpha, 0.0, 1.0));
	ALBEDO = color.rgb;
	ALPHA = color.a;
	
	// Bajarle el alpha al borde solo
	if (!(texture(spriteTexture, UV).a > 0.0) && ALPHA > 0.0) {
		ALPHA = borderAlpha;
	} else {
		ALBEDO *= modulate.rgb;
		ALPHA *= modulate.a;
	}
	
	// Por alguna razón todo se ve muy blown up si no hago esto
	ALBEDO *= .5;
}