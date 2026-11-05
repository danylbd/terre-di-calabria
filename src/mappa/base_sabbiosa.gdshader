shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float base = smoothstep(0.64, 0.76, UV.y);
	float chiaro = smoothstep(0.72, 0.94, dot(tex.rgb, vec3(0.299, 0.587, 0.114)));
	tex.rgb = mix(tex.rgb, tex.rgb * vec3(0.82, 0.72, 0.55), base * chiaro * tex.a);
	COLOR = tex * COLOR;
}
