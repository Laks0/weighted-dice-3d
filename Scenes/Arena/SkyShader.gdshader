shader_type sky;

uniform sampler2D noise;

uniform vec3 sky_color : source_color;

uniform float first_layer_opacity = .05;
uniform float first_layer_cutoff = .2;

uniform float second_layer_opacity = .1;
uniform float second_layer_cutoff = .5;

uniform sampler2D star_mask_noise;

void sky() {
	vec2 noise_coords = SKY_COORDS + TIME * .001;
	vec3 noise_texture = vec3(0.0);
	
	vec3 first_layer = step(first_layer_cutoff + sin(TIME*.7) * .15, texture(noise, noise_coords).rgb);
	noise_texture += first_layer * first_layer_opacity;
	
	vec2 second_layer_coords = SKY_COORDS + TIME * .001 * vec2(.0,-1.0);
	vec3 second_layer = step(second_layer_cutoff, texture(noise, second_layer_coords).rgb);
	noise_texture += second_layer * second_layer_opacity;
	
	COLOR = noise_texture * sky_color + sky_color * .05;
	
	vec3 star_texture = smoothstep(.9, 1., texture(noise, SKY_COORDS + TIME * vec2(0.0, .01)).rgb);
	COLOR += star_texture * step(.7, texture(star_mask_noise, SKY_COORDS + TIME * .001).xyz);
}
