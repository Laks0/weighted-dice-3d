shader_type spatial;
render_mode unshaded;

float getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_projection_matrix){
//	Credit: https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
	float raw_depth = texture(depth_texture, screen_uv)[0];
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
	view_space.xyz /= view_space.w;
	return -view_space.z;
}

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
const int pixel_size = 4; //resolution must be divisible by pixel_size

uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform vec3 shadow_color : source_color = vec3(0.0);

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);

	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;
	
	vec2 pixelated_uv = vec2(x, y) / VIEWPORT_SIZE;
	
	ALBEDO = texture(SCREEN_TEXTURE, pixelated_uv).rgb;
	
	vec2 e = vec2(1./VIEWPORT_SIZE.xy);
	
//	Shadows
	//float mean_depth_diff = 0.0;
	//for (int i = 0; i < 5; i++) {
		//vec2 screen_pos = pixelated_uv;
		//switch (i) {
			//case 0:
				//screen_pos += e;
				//break;
			//case 1:
				//screen_pos -= e;
				//break;
			//case 2:
				//screen_pos += vec2(.0, e.y);
				//break;
			//case 3:
				//screen_pos += vec2(e.x, .0);
				//break;
		//}
		//
		//float depth_diff = 0.0;
		//float neg_depth_diff = .5;
		//float depth = getDepth(screen_pos, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//float du = getDepth(screen_pos+vec2(0., -1.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//float dr = getDepth(screen_pos+vec2(1., 0.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//float dd = getDepth(screen_pos+vec2(0., 1.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//float dl = getDepth(screen_pos+vec2(-1., 0.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//depth_diff += clamp(du - depth, 0., 1.);
		//depth_diff += clamp(dd - depth, 0., 1.);
		//depth_diff += clamp(dr - depth, 0., 1.);
		//depth_diff += clamp(dl - depth, 0., 1.);
		//neg_depth_diff += depth - du;
		//neg_depth_diff += depth - dd;
		//neg_depth_diff += depth - dr;
		//neg_depth_diff += depth - dl;
		//neg_depth_diff = clamp(neg_depth_diff, 0., 1.);
		//neg_depth_diff = clamp(smoothstep(0.5, 0.5, neg_depth_diff)*10., 0., 1.);
		//depth_diff = smoothstep(0.2, 0.3, depth_diff);
		//
		//mean_depth_diff += depth_diff;
	//}
	////mean_depth_diff /= 2.;
	//
	//vec3 shadow_final_color = mix(ALBEDO, shadow_color, shadow_strength);
	//
	//ALBEDO = mix(ALBEDO, shadow_final_color, mean_depth_diff);
}