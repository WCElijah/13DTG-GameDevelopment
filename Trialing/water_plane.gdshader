// Based on https://youtu.be/7L6ZUYj1hs8?si=H4XmDMifrR0EQtV3

shader_type spatial;

uniform vec3 albedo : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 normal_blend = mix(texture(texture_normal, UV).rgb, texture(texture_normal2, UV).rgb, 0.5);
	// Called for every pixel the material is visible on.
	ALBEDO = albedo;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
