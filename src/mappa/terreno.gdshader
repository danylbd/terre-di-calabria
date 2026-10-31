shader_type canvas_item;
// Terreno continuo: fonde 8 texture dipinte con bordi irregolari, ombreggia il rilievo
// e anima il mare con riflessi e schiuma sulla riva.

uniform sampler2D pesi_a : filter_linear;   // prato, bosco, sabbia, roccia
uniform sampler2D pesi_b : filter_linear;   // neve, acqua, terra, secco
uniform vec2 dim_pesi;

uniform sampler2D t_prato : repeat_enable, filter_linear_mipmap;
uniform sampler2D t_bosco : repeat_enable, filter_linear_mipmap;
uniform sampler2D t_sabbia : repeat_enable, filter_linear_mipmap;
uniform sampler2D t_roccia : repeat_enable, filter_linear_mipmap;
uniform sampler2D t_neve : repeat_enable, filter_linear_mipmap;
uniform sampler2D t_acqua : repeat_enable, filter_linear_mipmap;
uniform sampler2D t_terra : repeat_enable, filter_linear_mipmap;
uniform sampler2D t_secco : repeat_enable, filter_linear_mipmap;
uniform sampler2D rumore : repeat_enable, filter_linear;

uniform float caselle_per_texture = 4.0;
uniform float morbidezza = 0.16;
uniform float tempo_fisso = -1.0;   // per le foto di prova; -1 = usa TIME
uniform float saturazione = 1.18;
uniform float contrasto = 1.08;
uniform float neve = 0.0;          // 0..1: d'inverno la neve copre la terra (non il mare)

varying vec2 coord;
varying float luce;

void vertex() {
	coord = UV;
	luce = COLOR.r * 1.25;
}

float somma4(vec4 v) { return v.x + v.y + v.z + v.w; }
float max4(vec4 v) { return max(max(v.x, v.y), max(v.z, v.w)); }

void fragment() {
	float t = tempo_fisso >= 0.0 ? tempo_fisso : TIME;
	vec2 tuv = (coord + 0.5) / dim_pesi;
	vec4 a = texture(pesi_a, tuv);
	vec4 b = texture(pesi_b, tuv);

	// bordi organici: ogni terreno ha la sua "altezza" di rumore che lo fa avanzare o arretrare
	vec4 ra = texture(rumore, coord * 0.09);
	vec4 rb = texture(rumore, coord * 0.09 + vec2(0.37, 0.61));
	vec4 wa = (a + ra * 0.5) * step(0.002, a);
	vec4 wb = (b + rb * 0.5) * step(0.002, b);
	float soglia = max(max4(wa), max4(wb)) - morbidezza;
	wa = max(wa - soglia, vec4(0.0));
	wb = max(wb - soglia, vec4(0.0));
	float s = somma4(wa) + somma4(wb) + 1e-5;
	wa /= s;
	wb /= s;

	vec2 tc = coord / caselle_per_texture;
	vec3 col = vec3(0.0);
	col += wa.x * texture(t_prato, tc).rgb;
	col += wa.y * texture(t_bosco, tc).rgb;
	col += wa.z * texture(t_sabbia, tc).rgb;
	col += wa.w * texture(t_roccia, tc * 0.7).rgb;
	col += wb.x * texture(t_neve, tc).rgb;
	col += wb.z * texture(t_terra, tc).rgb;
	col += wb.w * texture(t_secco, tc).rgb;

	// neve d'inverno: copre prima i pendii alti e lascia scoperte chiazze irregolari
	if (neve > 0.001) {
		float chiazze = texture(rumore, coord * 0.05 + vec2(0.13, 0.71)).r;
		float copre = clamp(neve * 1.6 - chiazze * 0.9 - wa.z * 0.6, 0.0, 1.0);
		vec3 bianco = texture(t_neve, tc).rgb * vec3(0.97, 0.99, 1.04);
		col = mix(col, bianco * (1.0 - wb.y), copre * (1.0 - wb.y));
	}

	// mare: due strati che scorrono, riflessi e schiuma a riva
	vec3 mare = texture(t_acqua, tc * 0.6 + vec2(t * 0.006, t * 0.004)).rgb * 0.55
	          + texture(t_acqua, tc * 1.1 - vec2(t * 0.009, -t * 0.003)).rgb * 0.45;
	float onde = texture(rumore, coord * 0.18 + vec2(t * 0.012, t * 0.008)).r;
	float onde2 = texture(rumore, coord * 0.26 - vec2(t * 0.01, t * 0.006)).g;
	mare += vec3(0.75, 0.85, 0.9) * smoothstep(0.7, 0.85, onde * onde2 * 1.9) * 0.18;
	float riva = smoothstep(0.15, 0.5, b.y) * smoothstep(0.98, 0.6, b.y);
	float schiuma = riva * smoothstep(0.35, 0.65, texture(rumore, coord * 0.8 + vec2(t * 0.05, 0.0)).b + sin(t * 1.5 + coord.x * 0.8) * 0.15);
	mare = mix(mare, vec3(0.9, 0.95, 0.95), schiuma * 0.7);
	col += wb.y * mare;

	// il rilievo ombreggia la terra ma non il mare
	float l = mix(luce, 1.0, wb.y);
	col *= l;
	float lum = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(lum), col, saturazione);
	col = (col - 0.5) * contrasto + 0.5;
	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
