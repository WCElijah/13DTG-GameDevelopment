// Waving flag shader, following GDQuest's "Flag shader 3D" tutorial
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noise_map : hint_default_black;
uniform vec2 noise_stretch = vec2(-0.2, -0.1);
uniform vec2 scroll_speed = vec2(0.3, 0.0);
uniform float depth_warp = 0.5;
uniform sampler2D flag_texture : source_color, hint_default_white;


void vertex() {
	float wave = texture(noise_map, UV * noise_stretch + TIME * scroll_speed).r * 2.0 - 1.0;
	// multiplying by UV.x keeps the edge on the pole still
	wave *= UV.x;

	VERTEX.y += wave;
	VERTEX.z += wave * depth_warp;
	VERTEX.x -= wave * depth_warp;
}


void fragment() {
	vec4 flag_colour = texture(flag_texture, UV);
	// see-through parts of the image show as white cloth instead of black
	ALBEDO = mix(vec3(1.0), flag_colour.rgb, flag_colour.a);
}
