shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 0.45;
uniform float radius : hint_range(0.1, 1.2) = 0.78;
uniform float softness : hint_range(0.05, 1.0) = 0.55;
uniform float grain : hint_range(0.0, 0.2) = 0.035;
uniform vec4 night_color : source_color = vec4(0.02, 0.015, 0.012, 1.0);
uniform float dread : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV - vec2(0.5);
    uv.x *= 1.12;
    float dist = length(uv);

    float edge = 1.0 - smoothstep(radius - softness, radius, dist);
    float a = (1.0 - edge) * (0.35 + darkness * 0.95) + darkness * 0.30;

    float g = (hash(UV * 1024.0 + vec2(TIME * 53.0, TIME * 29.0)) - 0.5) * grain;

    vec3 tint = mix(night_color.rgb, vec3(0.16, 0.03, 0.03), dread * (1.0 - edge));

    COLOR = vec4(tint + g * 0.5, clamp(a + g, 0.0, 1.0));
}
