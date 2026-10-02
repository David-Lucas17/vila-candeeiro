shader_type canvas_item;

uniform float light_energy : hint_range(0.0, 1.5) = 1.0;
uniform vec2 light_pos = vec2(0.26, 0.62);
uniform float flicker = 1.0;
uniform vec4 clay_color : source_color = vec4(0.30, 0.19, 0.12, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.68, 0.26, 1.0);

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float sum = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 5; i++) {
        sum += value_noise(p) * amp;
        p *= 2.03;
        amp *= 0.5;
    }
    return sum;
}

void fragment() {
    vec2 uv = UV;

    float clay = fbm(uv * vec2(9.0, 26.0));
    float straw = fbm(uv * vec2(70.0, 6.0)) * 0.35;
    float grit = hash(floor(uv * 520.0)) * 0.10;
    float surface = clay * 0.65 + straw + grit;

    float floor_line = smoothstep(0.74, 0.80, uv.y);
    vec3 base = mix(clay_color.rgb, clay_color.rgb * 0.45, floor_line);
    base *= 0.55 + surface * 0.9;

    vec2 d = uv - light_pos;
    d.x *= 1.22;
    float dist = length(d);
    float fall = 1.0 / (1.0 + 16.0 * dist * dist);
    float lit = fall * light_energy * flicker;

    float relief = (surface - 0.45) * lit * 0.8;

    vec3 col = base * (0.10 + lit * 1.55) + flame_color.rgb * (lit * 0.30 + relief * 0.35);

    col *= 1.0 - smoothstep(0.55, 0.0, uv.y) * 0.35 * (1.0 - lit);

    COLOR = vec4(col, 1.0);
}
