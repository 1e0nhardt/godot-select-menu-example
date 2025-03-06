shader_type canvas_item;

uniform vec3 border_color: source_color = vec3(0.9, 0.9, 0.45);
uniform float smooth_factor = 0.005;
uniform float corner_radius = 0.05;
uniform vec2 size = vec2(0.8, 0.85);
uniform vec2 line_width = vec2(0.05, 0.04);
uniform vec2 hollow = vec2(0.3, 0.2);
uniform vec2 iResolution;
uniform float radius = 0.65;

float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

float circle(vec2 p, float r) {
    return smoothstep(r + 0.01, r - 0.01, length(p));
}

void fragment() {
    vec2 uv = vec2(UV.x, 1.0 - UV.y);
    uv = uv * 2.0 - 1.0;
    float d = 0.0;
    float box_1 = sdRoundedBox(uv, size, vec4(corner_radius));
    float box_2 = sdRoundedBox(uv, size + line_width, vec4(corner_radius));
    d =  smoothstep(-smooth_factor, smooth_factor, box_1) * smoothstep(smooth_factor, -smooth_factor, box_2);
    vec2 h = smoothstep(hollow - vec2(smooth_factor), hollow + vec2(smooth_factor), abs(uv));
    d *= h.x * h.y;

    uv.x *= iResolution.x / iResolution.y;
    float center_circle = circle(uv, radius) * 0.4;
    d += center_circle;

    vec3 color = mix(border_color, vec3(0.4), center_circle);
    COLOR = vec4(color, d);
}
