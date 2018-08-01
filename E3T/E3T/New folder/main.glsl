#version 400 core
#import "SDF_lib.glsl"
in vec2 fragPos;
out vec4 fragColor;


// TODO: switch loop fom maxDist to maxStep for loop unreveling
// eliminate bransches

uniform float u_dt;
uniform float u_v;
uniform vec2 u_resolution;
uniform vec3 u_camUp;
uniform vec3 u_camRight;
uniform vec3 u_eye;

const int M_NONE = -1;
const int M_FLOOR = 0;
const int M_SPHERE = 1;
const int M_BOX = 2;
const int M_TORUS = 3;
const int M_Capsule = 4;
const int M_PRISM = 5;
const int M_CYLINDER = 6;
const int M_CONE = 7;
const int M_PRYAMID_CONE = 8;


const float minDist = 0.0;
const float maxDist = 50.0;
const int maxStep = 50;
const float epsilon = 0.0001;

float SD_Scene(vec3 p, out int material)
{
/*
	float cylinder = SD_Cylinder(p.yxz, vec2(0.1, 0.3));
	float box = SD_Box(p, vec3(0.1, 0.9, 0.4));
		
	return opU(SD_yPlane(p), M_FLOOR, opCombine(box, cylinder, 0.02), M_SPHERE, material);
*/

	float dist = 
		opU(SD_yPlane(p), M_FLOOR, SD_Sphere(	p-vec3( 0.0,-0.75, 0.0), 0.25), 						M_SPHERE, material);
	dist = opU(dist, material, SD_Box(			p-vec3( 1.0,-0.75, 0.0), vec3(0.25)), 					M_BOX, material);
	dist = opU(dist, material, UD_RoundBox(		p-vec3( 1.0,-0.75, 1.0), vec3(0.15), 0.1), 				M_BOX, material);
	dist = opU(dist, material, SD_Torus(		p-vec3( 0.0,-0.75, 1.0), vec2(0.20,0.05)), 				M_TORUS, material);
	dist = opU(dist, material, SD_Torus82(		p-vec3( 0.0,-0.75, 2.0), vec2(0.20,0.05)),				M_TORUS, material);
	dist = opU(dist, material, SD_Torus88(		p-vec3(-2.0,-0.75 ,-2.0), vec2(0.20,0.05)),				M_TORUS, material);
	dist = opU(dist, material, SD_Capsule(		p,vec3(-1.3,-0.90,-0.1), vec3(-0.8,-0.50,0.2), 0.1),	M_Capsule, material);
	dist = opU(dist, material, SD_TriPrism(		p-vec3(-1.0,-0.75,-1.0), vec2(0.25,0.05)),				M_PRISM, material);
	dist = opU(dist, material, SD_HexPrism(		p-vec3(-1.0,-0.80, 1.0), vec2(0.25,0.05)),				M_PRISM, material);
	dist = opU(dist, material, SD_Cylinder(		p-vec3( 1.0,-0.60,-1.0), vec2(0.1,0.2)),				M_CYLINDER, material);
	dist = opU(dist, material, SD_Cylinder6(	p-vec3( 1.0,-0.60, 2.0), vec2(0.1,0.2)),				M_CYLINDER, material);
	dist = opU(dist, material, SD_Cone(			p-vec3( 0.0,-0.50,-1.0), vec3(0.8,0.6,0.3)),			M_PRYAMID_CONE, material);
	dist = opU(dist, material, SD_Pyramid4(		p-vec3(-1.0,-0.85,-2.0), vec3(0.8,0.6,0.25)),			M_PRYAMID_CONE, material);
	dist = opU(dist, material, SD_Octahedron(	p-vec3(-1.0,-0.5 , 2.0), vec3(0.8,0.6,0.25)),			M_PRYAMID_CONE, material);
	dist = opU(dist, material, opD(UD_RoundBox(	p-vec3(-2.0,-0.8 , 1.0), vec3(0.15), 0.05),
							   SD_Sphere(		p-vec3(-2.0,-0.8 , 1.0), 0.25)), 						M_BOX, material);
	dist = opU(dist, material, opD(SD_Torus82(	p-vec3(-2.0,-0.8 , 0.0), vec2(0.20,0.1)), SD_Cylinder(repeat(vec3(atan(p.x + 2.0, p.z) / 6.2831, p.y,
							0.02 + 0.5 * length(p-vec3(-2.0,-0.8 , 0.0))),vec3(0.05, 1.0, 0.05)), vec2(0.02, 0.6))),
																										M_TORUS, material);
	dist = opU(dist, material, 0.5 * SD_Sphere(	p-vec3(-2.0,-0.75,-1.0), 0.2) + 0.03*sin(50.0*p.x)*sin(50.0*p.y)*sin(50.0*p.z),			
																										M_SPHERE, material);
	dist = opU(dist,material,0.5*SD_Torus(twist(p-vec3(-2.0,-0.75, 2.0)),vec2(0.20,0.05)),				M_TORUS, material);
	dist = opU(dist, material, SD_ConeSection(	p-vec3( 0.0,-0.65,-2.0), 0.15, vec2(0.2,0.1)),			M_PRYAMID_CONE, material);
	dist = opU(dist, material, SD_Ellipsoid(	p-vec3( 1.0,-0.65,-2.0), vec3(0.15, 0.2, 0.05)),		M_SPHERE, material);
																									
    return dist;

	/*
    float plane = SD_yPlane(p);
   	p.x = mod(p.x, 1.5 * 2.0) - 1.5;
    p.z = mod(p.z, 1.5 * 2.0) - 1.5;
	
	vec3 q = p * rotateX(u_v / 3.0) * rotateY(u_v / 5.0);
	float holowBox = opD(SD_Box(q, vec3(0.5)), SD_Sphere(q, (sin(u_v) + 1.5) / 2.0));
	return opU(plane, M_FLOOR, opU(holowBox, M_BOX, SD_Torus(p * rotateX(u_v), vec2(0.25, 0.1)), M_TORUS, material), material, material);
*/
}
float castRay(vec3 dir, out int material)
{
	material = M_NONE;
	int m;
	float totalDist = minDist;
	int steps = 0;
	while (totalDist < maxDist)
    {
        float dist = SD_Scene(dir * totalDist + u_eye, m);
        if(dist < epsilon || ++steps > maxStep) break;
		material = m;
        totalDist += dist;
    }
	if(totalDist > maxDist) material = M_NONE;
	return totalDist;
}
vec3 getNormal(vec3 p)
{
	const float h = 0.0001f;
	int m;
	return normalize(vec3(
		SD_Scene(p + vec3(h, 0, 0), m) - SD_Scene(p - vec3(h, 0, 0), m),
		SD_Scene(p + vec3(0, h, 0), m) - SD_Scene(p - vec3(0, h, 0), m),
		SD_Scene(p + vec3(0, 0, h), m) - SD_Scene(p - vec3(0, 0, h), m)));
}
float checkersGradBox(vec2 p)
{
    // filter kernel
    vec2 w = fwidth(p) + 0.001;
    // analytical integral (box filter)
    vec2 i = 2.0*(abs(fract((p-0.5*w)*0.5)-0.5)-abs(fract((p+0.5*w)*0.5)-0.5))/w;
    // xor pattern
    return 0.5 - 0.5 * i.x * i.y;
}
float calcAmbientOcclusio(vec3 p, vec3 norm)
{
	float occ = 0.0;
    float sca = 1.0;
	int m;
    for (int i = 0; i < 5; ++i)
    {
        float hr = 0.01 + 0.12 * float(i) / 4.0;
        vec3 aoPos =  norm * hr + p;
        float dd = SD_Scene(aoPos, m);
        occ += -(dd - hr) * sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );   
}
float calcShadow(vec3 p, vec3 dir, float minDist, float maxDist)
{
	int m;
	int steps = 0;
	for (float totalDist = minDist; totalDist < maxDist;)
    {
        float dist = SD_Scene(dir * totalDist + p, m);
        if(dist < epsilon || ++steps > maxStep) return 0.0;
        totalDist += dist;
    }
    return 1.0;
}
float calcSoftshadowCheap(vec3 p, vec3 dir, float minDist, float maxDist, float k)
{
	int m;
    float res = 1.0;
	int steps = 0;
	for (float totalDist = minDist; totalDist < maxDist;)
    {
        float dist = SD_Scene(dir * totalDist + p, m);
        if(dist < epsilon || ++steps > maxStep) return 0.0;
		res = min(res, k * dist / totalDist);
        totalDist += dist;
    }
    return res;
}
float calcSoftshadow(vec3 p, vec3 dir, float minDist, float maxDist, float k)
{
	int m;
    float res = 1.0;
	float ph = 1e20;
	int steps = 0;
	for (float totalDist = minDist; totalDist < maxDist;)
    {
        float dist = SD_Scene(p + dir * totalDist, m);
        if(dist < epsilon || ++steps > maxStep) return 0.0;

		float distSq = dist*dist;
		float y = distSq/(2.0*ph);
		float d = sqrt(distSq-y*y);
		res = min(res, k * dist / max(0.0, totalDist - y));
		ph = dist;
        totalDist += dist;
    }
    return res;
}
vec3 render(vec3 dir)
{
    vec3 col = dir.y * 0.8 + vec3(0.7, 0.9, 1.0);
	int material;
	float dist = castRay(dir, material);

	if(material != M_NONE)
	{
		vec3 pos = dir * dist + u_eye;
		vec3 norm = getNormal(pos);
        vec3 ref = reflect(dir, norm);

		
		switch (material)
		{
		case M_FLOOR:
			col = vec3(checkersGradBox(pos.xz * 5.0) * 0.5)  + 0.3;
		break;
		case M_SPHERE:			col = vec3(1.0, 0.0, 0.0); break;
		case M_BOX:				col = vec3(0.0, 1.0, 0.0); break;
		case M_TORUS:			col = vec3(0.0, 0.0, 1.0); break;
		case M_Capsule:			col = vec3(1.0, 1.0, 0.0); break;
		case M_PRISM:			col = vec3(0.0, 1.0, 1.0); break;
		case M_CYLINDER:		col = vec3(1.0, 0.0, 1.0); break;
		case M_CONE:			col = vec3(0.5, 1.0, 0.0); break;
		case M_PRYAMID_CONE: 	col = vec3(0.0, 1.0, 0.5); break;
		default: return col;
		}
		float occ = calcAmbientOcclusio(pos, norm);
		const vec3 lightPos = normalize(vec3(-0.4, 0.7, -0.6));
		vec3 hal = normalize(lightPos - dir);
		float ambient = clamp(0.5 + 0.5 * norm.y, 0.0, 1.0);
		float diffuse = clamp(dot(norm, lightPos), 0.0, 1.0);
		float bac = clamp(dot(norm, normalize(vec3(-lightPos.x, 0.0,-lightPos.z))), 0.0, 1.0) * clamp(1.0 - pos.y, 0.0, 1.0);
		float dom = smoothstep(-0.1, 0.1, ref.y);
		float fre = pow(clamp(1.0+dot(norm, dir), 0.0, 1.0), 2.0);

        diffuse *=  calcShadow(pos, lightPos, 0.02, 2.5);
        dom *= 		calcShadow(pos, ref, 0.02, 2.5);

		float specular = pow(clamp(dot(norm, hal), 0.0, 1.0), 16.0) *
					diffuse * (0.04 + 0.96*pow(clamp(1.0 + dot(hal, dir), 0.0, 1.0), 5.0));

		vec3 light = vec3(0.0);
        light += 0.40 * ambient *	vec3(0.40,0.60,1.00)*occ;
		light += 1.30 * diffuse *	vec3(1.00,0.80,0.55);
        light += 0.50 * bac *		vec3(0.25,0.25,0.25)*occ;
        light += 0.50 * dom *		vec3(0.40,0.60,1.00)*occ;
        light += 0.25 * fre *		vec3(1.00,1.00,1.00)*occ;
		col *= light;
		col += 	10.00 * specular * 	vec3(1.00,0.90,0.70);

    	col = mix(col, vec3(0.8,0.9,1.0), 1.0-exp(-0.0002*pow(dist, 3)));
	}
	return col;
}
void main()
{
	const float focalLength = 1.67;
	vec3 dir = normalize(
		cross(u_camRight, u_camUp) // camForward
 		* focalLength + u_camRight * fragPos.x * 
		(u_resolution.x / u_resolution.y) + u_camUp * fragPos.y);

	vec3 col = render(dir);
	// gamma
	col = pow(col, vec3(0.4545));
	fragColor = vec4(col, 1.0);
}

