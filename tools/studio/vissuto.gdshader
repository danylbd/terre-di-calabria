shader_type spatial;
// Materiale "vissuto" per lo studio: texture triplanare, sporco e umidità alla base dei muri,
// macchie e colature, finta occlusione nelle parti rivolte in basso, colori più saturi.

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D rumore : filter_linear, repeat_enable;
uniform float scala = 2.0;
uniform float sporco = 0.45;
uniform float macchie = 0.35;
uniform float saturazione = 1.25;
uniform float contrasto = 1.12;
uniform vec3 tinta = vec3(1.0);
uniform float ruvidezza = 0.9;
uniform float metallo = 0.0;

varying vec3 wpos;
varying vec3 wnorm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = pow(abs(wnorm), vec3(4.0));
	n /= (n.x + n.y + n.z);
	vec3 p = wpos * scala;
	vec3 c = texture(tex, p.zy).rgb * n.x + texture(tex, p.xz).rgb * n.y + texture(tex, p.xy).rgb * n.z;
	c *= tinta;
	float r = texture(rumore, wpos.xz * 1.7 + vec2(wpos.y * 0.9)).r;
	// terra e umidità alla base
	float base = 1.0 - smoothstep(0.0, 0.22, wpos.y);
	c = mix(c, c * vec3(0.5, 0.42, 0.32), base * sporco * (0.55 + 0.45 * r));
	// macchie e colature verticali
	float st = smoothstep(0.58, 0.82, texture(rumore, vec2(wpos.x * 2.3 + wpos.z * 2.1, wpos.y * 0.5)).g);
	c *= 1.0 - st * macchie * 0.45;
	// grana fine
	c *= 0.9 + 0.2 * texture(rumore, p.xz * 3.1 + p.y * 2.3).b;
	// finta occlusione: le parti rivolte verso il basso sono più scure
	c *= mix(0.45, 1.0, smoothstep(-0.7, 0.35, wnorm.y));
	// colori saturi e contrastati
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(l), c, saturazione);
	c = (c - 0.5) * contrasto + 0.5;
	ALBEDO = clamp(c, 0.0, 1.0);
	ROUGHNESS = ruvidezza;
	METALLIC = metallo;
}
