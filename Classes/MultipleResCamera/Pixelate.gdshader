shader_type spatial;
render_mode unshaded, fog_disabled;

uniform vec3 shadow_color : source_color = vec3(0.0);
uniform float shadow_thickness = 2.0;

uniform sampler2D white_border_texture : hint_default_transparent;

vec2 getDepth(vec2 screen_pos, sampler2D depth_texture, mat4 inv_projection_matrix){
	float raw_depth = texture(depth_texture, screen_pos)[0];
	vec3 normalized_device_coordinates = vec3(screen_pos * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
	view_space.xyz /= view_space.w;
	return vec2(-view_space.z, raw_depth);
}

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;
const int pixel_size = 4; //resolution must be divisible by pixel_size

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);

	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

	vec2 pixelated_uv = vec2(x, y) / VIEWPORT_SIZE;
	// Outlines
	vec2 e = vec2(1./VIEWPORT_SIZE.xy);

	float depth_diff = 0.0;
	float neg_depth_diff = .5;

	vec2 screen_pos = pixelated_uv;

	vec2 depth_data = getDepth(screen_pos, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
	float depth = depth_data.x;
	vec3 color = texture(SCREEN_TEXTURE, screen_pos).rgb;
	vec3 c = vec3(0.0);

	vec2 min_depth_data = depth_data;
	float min_depth = 9999999.9;


	vec3 normal = texture(NORMAL_TEXTURE, screen_pos).rgb * 2.0 - 1.0;
	
	bool any_neighbour_in_white_border = false;
	
	for (float x = -shadow_thickness; x <= shadow_thickness;x += 1.0){
		for (float y = -shadow_thickness; y <= shadow_thickness; y += 1.0){
			if ((x == 0.0 && y == 0.0) || (shadow_thickness*shadow_thickness < (x*x + y*y))){
				continue;
			}

			any_neighbour_in_white_border = any_neighbour_in_white_border || texture(white_border_texture, screen_pos+vec2(x, y)*e).a > .0;

			vec2 du_data = getDepth(screen_pos+1.0*vec2(x, y)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
			vec2 dd_data = getDepth(screen_pos+0.5*vec2(x, y)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);

			float du = du_data.x;
			float dd = dd_data.x;

			float dd_diff = clamp(abs((depth - dd) - (dd - du)), 0.0, 1.0);

			float val = clamp(abs(depth - du), 0., 1.)/(x*x + y*y)*dd_diff*dd_diff*5000.0;

			val = clamp(val, 0.0, 1.0);

			depth_diff += val;

			if (du < min_depth){
				min_depth = du;
				min_depth_data = du_data;
				c = texture(SCREEN_TEXTURE, screen_pos+vec2(x, y)*e).rgb;

				c *= clamp(0.5+ 0.5*dot(normalize(vec2(x, y)), (vec2(0.0, 1.0))), 0.0, 1.0);

			}

			vec3 nu = texture(NORMAL_TEXTURE, screen_pos+vec2(x, y)*e).rgb * 2.0 - 1.0;

			depth_diff += (1.0-abs(dot(nu, normal)))/max(min(dd, depth), 2.0);
		}
	}
	depth_diff = smoothstep(0.5, 0.7, depth_diff) * .95;

	ALBEDO = texture(SCREEN_TEXTURE, pixelated_uv).rgb;
	vec3 final_shadow_color = shadow_color;
	if (any_neighbour_in_white_border) {
		final_shadow_color = vec3(1.0);
	}
	ALBEDO = mix(ALBEDO, final_shadow_color, depth_diff);
}