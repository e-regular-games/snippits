shader_type spatial;
render_mode world_vertex_coords;

uniform float amplitude = 1.0;
uniform float scale = 1.0;
uniform float speed = 1.0;
uniform bool emission = false;
uniform sampler2D noise;

uniform vec4 low_color: hint_color;
uniform vec4 high_color: hint_color;

void vertex() {
	ivec2 ns = textureSize(noise, 0);
	float nx = VERTEX.x * scale + TIME * speed;
	float nz = VERTEX.z * scale;
	vec2 n = vec2(nx, nz);
	float ratio = texture(noise, n).r;
	VERTEX.y += amplitude * 2.0 * (ratio - 0.5);
	UV = vec2(ratio);
}

void fragment() {
	float ratio = (UV.x < 0.5 ? -0.5 : 0.5) * pow(abs(UV.x - 0.5) * 2.0, 0.7) + 0.5;
	if (emission) {
		EMISSION = mix(low_color, high_color, ratio).rgb;
		ALBEDO.rgb = vec3(0);
	} else {
		ALBEDO.rgb = mix(low_color, high_color, ratio).rgb;
	}
	
	ALPHA = mix(low_color, high_color, ratio).a;	
}