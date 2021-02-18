// Shader code partially migrated from:
// https://github.com/dsoft20/psx_retroshader
shader_type spatial;
render_mode skip_vertex_transform;

uniform sampler2D albedo_texture;
uniform vec2 uv_scale = vec2(1.0);
uniform vec4 emission : hint_color = vec4(0.0); 

varying vec4 vertex_coords;

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	
	// Limit vertices precision on screen
	vec2 resolution = vec2(320.0, 240.0) * 0.75;
	float coord_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
	VERTEX.xy = coord_w * floor(resolution * VERTEX.xy / coord_w) / resolution;
	
	// Affine texture coords
	vec2 uv = UV * uv_scale;
	vertex_coords = vec4(uv * VERTEX.z, VERTEX.z, 0.0);
}

void fragment() {
	vec4 color = texture(albedo_texture, vertex_coords.xy / vertex_coords.z);
	
	ALBEDO = color.rgb * color.rgb;
	EMISSION = emission.rgb;
}