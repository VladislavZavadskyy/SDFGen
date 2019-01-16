#version 450

uniform sampler2D meshtex;
// uniform sampler2D meshuvtex;
// uniform sampler2D basetex;
uniform int meshverts;

in vec2 texCoord;

out vec4 fragColor;

const float res = 150.0; // sdftex res
const float res2 = res * res;

float dot2(const vec3 v) {
	return dot(v, v);
}

float udTriangle(const vec3 p, const vec3 a, const vec3 b, const vec3 c) {
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 ac = a - c; vec3 pc = p - c;
    vec3 nor = cross(ba, ac);

    return sqrt(
    (sign(dot(cross(ba, nor), pa)) +
     sign(dot(cross(cb, nor), pb)) +
     sign(dot(cross(ac, nor), pc)) < 2.0)
     ?
     min(min(
     dot2(ba * clamp(dot(ba, pa) / dot2(ba), 0.0, 1.0) - pa),
     dot2(cb * clamp(dot(cb, pb) / dot2(cb), 0.0, 1.0) - pb)),
     dot2(ac * clamp(dot(ac, pc) / dot2(ac), 0.0, 1.0) - pc))
     :
     dot(nor, pa) * dot(nor, pa) / dot2(nor));
}

// from wiki
int mollerTrumbore(vec3 rayOrigin, vec3 rayVector,
                    const vec3 vertex0, const vec3 vertex1, const vec3 vertex2)
{
    const float EPSILON = 1e-7;// 0.0000001;
    vec3 edge1, edge2, h, s, q;
    float a, f, u, v;
    edge1 = vertex1 - vertex0;
    edge2 = vertex2 - vertex0;

    h = cross(rayVector, edge2);
    a = dot(edge1, h);
    if (a > -EPSILON && a < EPSILON){
        return 0;    // This ray is parallel to this triangle.
		}
    f = 1.0 / a;
    s = rayOrigin - vertex0;
    u = f * dot(s,h);
    if (u < 0.0 || u > 1.0 || u == 0.0 || u == 1.0) {
        return 0;
	}
    q = cross(s,edge1);
    v = f * dot(rayVector,q);
    if (v < 0.0 || u + v > 1.0 || v == 0.0 || (u+v) == 1.0) {
        return 0;
		}
    // At this stage we can compute t to find out where the intersection point is on the line.
    float t = f * dot(edge2,q);
    if (t > EPSILON) {
        return 1; // ray intersection
    }
		// This means that there is a line intersection but not a ray intersection.
    return 0;
}

ivec2 getco(const int i) {
	const int stride = 16384;
    return ivec2(i % stride, int(i / stride));
}

void main() {

	// 0:1 x 0:1 -> 0:res x 0:res2
	vec2 co = texCoord * vec2(res, res2);
	// -> 0:res x 0:res x 0:res
	vec3 pos = vec3(int(co.x) % int(res), int(co.y) % int(res), int(co.x / res) * res + int(co.y / res));
	// -> -1:1 x -1:1 x -1:1
	pos = (pos / res) * 2.0 - 1.0;

	float dist = 10000.0;
    	vec3 col = vec3(0.0);
	int hits = 0;
	const vec3 ray = vec3(1.0, 0.0, 0.0);
	for (int i = 0; i < meshverts; i += 3) {
		vec3 a = texelFetch(meshtex, getco(i), 0).rgb;
		vec3 b = texelFetch(meshtex, getco(i + 1), 0).rgb;
		vec3 c = texelFetch(meshtex, getco(i + 2), 0).rgb;
		float d = udTriangle(pos, a, b, c);
		dist = min(dist, d);
		hits += mollerTrumbore(pos, ray, a, b, c);

        // Found closer surface
        // if (d == dist) {
            // TODO: interpolate UV
            // vec2 uva = texelFetch(meshuvtex, getco(i), 0).rg;
            // vec2 uvb = texelFetch(meshuvtex, getco(i + 1), 0).rg;
            // vec2 uvc = texelFetch(meshuvtex, getco(i + 2), 0).rg;

            // float minx = min(a.x, min(b.x, c.x));
            // float maxx = max(a.x, max(b.x, c.x));
            // float miny = min(a.y, min(b.y, c.y));
            // float maxy = max(a.y, max(b.y, c.y));
            // float minz = min(a.z, min(b.z, c.z));
            // float maxz = max(a.z, max(b.z, c.z));

            // col = texture(basetex, uva).rgb;
        // }
	}

	  int inside = hits % 2 == 0 ? 1 : -1;
    float distout = abs(dist) * inside;
    // float distout = abs(dist);

    // fragColor.rgb = col;
    // fragColor.a = distout;
    fragColor.r = distout;
}
