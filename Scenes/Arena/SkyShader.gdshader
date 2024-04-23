shader_type sky;

uniform sampler2D noise;

uniform vec3 sky_color : source_color;

uniform float first_layer_opacity = .05;
uniform float first_layer_cutoff = .2;

uniform float second_layer_opacity = .1;
uniform float second_layer_cutoff = .5;

uniform float speed = 1.;

uniform sampler2D rotation_noise;
uniform float rotation_strength = .0;

uniform sampler2D star_mask_noise;

void sky() {
	if (AT_CUBEMAP_PASS) {
		COLOR = sky_color;
	} else {
		float theta = acos(dot(EYEDIR, vec3(0, 1, 0)));
		float phi = atan(EYEDIR.z, EYEDIR.x);
		float r = 2.0 * tan(theta / 2.0);
		vec2 stereographic = r * vec2(cos(phi), sin(phi)) * .1;
		
		vec2 noise_coords = stereographic + speed * TIME * .001;
		vec3 noise_texture = vec3(0.0);
		
		float angle = texture(rotation_noise, stereographic).r * rotation_strength;
		mat2 rotation = mat2(vec2(sin(angle), -cos(angle)), vec2(cos(angle), sin(angle)));
		noise_coords = noise_coords * rotation;
		
		vec3 first_layer = step(first_layer_cutoff + sin(TIME*.7 * speed) * .15, texture(noise, noise_coords).rgb);
		noise_texture += first_layer * first_layer_opacity;
		
		vec2 second_layer_coords = stereographic + speed * TIME * .001 * vec2(.0,-1.0);
		second_layer_coords = second_layer_coords * rotation;
		vec3 second_layer = step(second_layer_cutoff, texture(noise, second_layer_coords).rgb);
		noise_texture += second_layer * second_layer_opacity;
		
		COLOR = noise_texture * sky_color + sky_color * .05;
		
		vec3 star_texture = step(.91, texture(noise, stereographic + speed * TIME * .005).rgb);
		COLOR += star_texture * step(.7, texture(star_mask_noise, stereographic).xyz);
	}
}
