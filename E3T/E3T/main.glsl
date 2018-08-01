#import "SDF_lib.glsl"
in vec2 fragPos;
out vec4 fragColor;


// eliminate bransches
// https://www.geeks3d.com/20140701/opengl-4-shader-subroutines-introduction-3d-programming-tutorial/

uniform float u_dt;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec3 u_camUp;
uniform vec3 u_camRight;
uniform vec3 u_eye;


const int 
M_NONE 			=-2,
M_FLOOR 		=-1,
M_SPHERE 		= 0,
M_BOX 			= 1,
M_TORUS 		= 2,
M_Capsule 		= 3,
M_PRISM 		= 4,
M_CYLINDER 		= 5,
M_CONE 			= 6,
M_PRYAMID_CONE 	= 7;

vec3 materialColors[8] = vec3[8](
	vec3(1.0, 0.0, 0.0),
	vec3(0.0, 1.0, 0.0),
	vec3(0.0, 0.0, 1.0),
	vec3(1.0, 1.0, 0.0),
	vec3(0.0, 1.0, 1.0),
	vec3(1.0, 0.0, 1.0),
	vec3(0.5, 1.0, 0.0),
	vec3(0.0, 1.0, 0.5)
);

const float minDist = 0.0;
const float maxDist= 20.0;
const int maxStep = 100;
const float epsilon = 0.001;
const float fogDist = 0.0004;



Material SD_Scene(vec3 p)
{
/*
	float cylinder = SD_Cylinder(p.yxz, vec2(0.1, 0.3));
	float box = SD_Box(p, vec3(0.1, 0.9, 0.4));
		
	return opU(SD_yPlane(p), M_FLOOR, opCombine(box, cylinder, 0.02), M_SPHERE, material);
*/
	//res = opU(res, Material(		SD_Ellipsoid(p, vec3(0.15, 0.2, 0.05)),	M_SPHERE));
	
	Material res =  opU(Material(SD_yPlane(p), 															M_FLOOR), 
				   Material(SD_Sphere(			p-vec3( 0.0,-0.75, 0.0), 0.25), 						M_SPHERE));
	res = opU(res, Material(SD_Box(				p-vec3( 1.0,-0.75, 0.0), vec3(0.25)), 					M_BOX));
	res = opU(res, Material(UD_RoundBox(		p-vec3( 1.0,-0.75, 1.0), vec3(0.15), 0.1), 				M_BOX));
	res = opU(res, Material(SD_Torus(			p-vec3( 0.0,-0.75, 1.0), vec2(0.20,0.05)), 				M_TORUS));
	res = opU(res, Material(SD_Torus82(			p-vec3( 0.0,-0.75, 2.0), vec2(0.20,0.05)),				M_TORUS));
	res = opU(res, Material(SD_Torus88(			p-vec3(-2.0,-0.75 ,-2.0), vec2(0.20,0.05)),				M_TORUS));
	res = opU(res, Material(SD_Capsule(			p,vec3(-1.3,-0.90,-0.1), vec3(-0.8,-0.50,0.2), 0.1),	M_Capsule));
	res = opU(res, Material(SD_TriPrism(		p-vec3(-1.0,-0.75,-1.0), vec2(0.25,0.05)),				M_PRISM));
	res = opU(res, Material(SD_HexPrism(		p-vec3(-1.0,-0.80, 1.0), vec2(0.25,0.05)),				M_PRISM));
	res = opU(res, Material(SD_Cylinder(		p-vec3( 1.0,-0.60,-1.0), vec2(0.1,0.2)),				M_CYLINDER));
	res = opU(res, Material(SD_Cylinder6(		p-vec3( 1.0,-0.60, 2.0), vec2(0.1,0.2)),				M_CYLINDER));
	res = opU(res, Material(SD_Cone(			p-vec3( 0.0,-0.50,-1.0), vec3(0.8,0.6,0.3)),			M_PRYAMID_CONE));
	res = opU(res, Material(SD_Pyramid4(		p-vec3(-1.0,-0.85,-2.0), vec3(0.8,0.6,0.25)),			M_PRYAMID_CONE));
	res = opU(res, Material(SD_Octahedron(		p-vec3(-1.0,-0.5 , 2.0), vec3(0.8,0.6,0.25)),			M_PRYAMID_CONE));
	res = opU(res, Material(opD(UD_RoundBox(	p-vec3(-2.0,-0.8 , 1.0), vec3(0.15), 0.05),
							   SD_Sphere(		p-vec3(-2.0,-0.8 , 1.0), 0.25)), 						M_BOX));
	res = opU(res, Material(opD(SD_Torus82(		p-vec3(-2.0,-0.8 , 0.0), vec2(0.20,0.1)), SD_Cylinder(repeat(vec3(atan(p.x + 2.0, p.z) / 6.2831, p.y,
						0.02 + 0.5 * length(	p-vec3(-2.0,-0.8 , 0.0))),vec3(0.05, 1.0, 0.05)), vec2(0.02, 0.6))),
																										M_TORUS));
	res = opU(res, Material(0.5 * SD_Sphere(	p-vec3(-2.0,-0.75,-1.0), 0.2) + 0.03*sin(50.0*p.x)*sin(50.0*p.y)*sin(50.0*p.z),			
																										M_SPHERE));
	res = opU(res, Material(0.5*SD_Torus(twist(	p-vec3(-2.0,-0.75, 2.0)),vec2(0.20,0.05)),				M_TORUS));
	res = opU(res, Material(SD_ConeSection(		p-vec3( 0.0,-0.65,-2.0), 0.15, vec2(0.2,0.1)),			M_PRYAMID_CONE));
	res = opU(res, Material(SD_Ellipsoid(		p-vec3( 1.0,-0.65,-2.0), vec3(0.15, 0.2, 0.05)),		M_SPHERE));
	res = opU(res, Material(SD_MandelBulb(		p-vec3( 0.0, 1.5 , 0.0), 8.0, 15, 5.0), 					M_SPHERE));
    return res;

	/*
    float plane = SD_yPlane(p);
   	p.x = mod(p.x, 1.5 * 2.0) - 1.5;
    p.z = mod(p.z, 1.5 * 2.0) - 1.5;
	
	vec3 q = p * rotateX(u_time / 3.0) * rotateY(u_time / 5.0);
	float holowBox = opD(SD_Box(q, vec3(0.5)), SD_Sphere(q, (sin(u_time) + 1.5) / 2.0));
	return opU(Material(plane, M_FLOOR), opU(Material(holowBox, M_BOX), Material(SD_Torus(p * rotateX(u_time), vec2(0.25, 0.1)), M_TORUS)));
*/
}
Material castRay(vec3 pos, vec3 dir)
{
	int m = M_NONE;
	float totalDist = minDist;
    for(int steps = 0; steps < maxStep; ++steps)
    {
	   	Material res = SD_Scene(pos + dir * totalDist);
	    m = res.material;
        if(res.dist < epsilon*totalDist || totalDist > maxDist) break;
        totalDist += res.dist;
    }

    //if(totalDist>maxDist) m = M_NONE;
    return Material(totalDist, m);
	/*int steps = 0;
	while (totalDist < maxDist)
    {
        float Dist = SD_Scene(dir * totalDist + pos, m);
        if(Dist < epsilon || ++steps > maxStep) break;
		material = m;
        totalDist += Dist;
    }
	if(totalDist > maxDist) material = M_NONE;
	return totalDist;*/
}
vec3 getNormal(vec3 p)
{
	const vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
	int m;
    return normalize( e.xyy*SD_Scene(p + e.xyy).dist + 
					  e.yyx*SD_Scene(p + e.yyx).dist + 
					  e.yxy*SD_Scene(p + e.yxy).dist + 
					  e.xxx*SD_Scene(p + e.xxx).dist );
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
    for (int i = 0; i < 5; ++i)
    {
        float hr = /*0.01 + */0.03 * float(i);
        vec3 aoPos =  norm * hr + p;
        float dd = SD_Scene(aoPos).dist;
        occ += -(dd - hr) * sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );   
}
float calcShadow(vec3 p, vec3 dir, const float minDist, const float maxDist)
{
	int steps = 0;
	for (float totalDist = minDist; totalDist < maxDist;)
    {
        float dist = SD_Scene(dir * totalDist + p).dist;
        if(dist < epsilon || ++steps > maxStep) return 0.0;
        totalDist += dist;
    }
    return 1.0;
}
float calcSoftshadow(vec3 p, vec3 dir, const float minDist, const float maxDist, const float k)
{
    float dist = 1.0;
	for (float totalDist = minDist; totalDist < maxDist;)
    {
        float dist = SD_Scene(dir * totalDist + p).dist;
		dist = min(dist, k * dist / totalDist);
        totalDist += dist;
        if(dist < epsilon) return 0.0;
	}
    return dist;
}
vec3 render(vec3 dir)
{
    vec3 col = dir.y * 0.8 + vec3(0.7, 0.9, 1.0);
	Material res = castRay(u_eye, dir);
	float dist = res.dist;
	int material = res.material;

	if(material != M_NONE)
	{
		vec3 pos = dir * dist + u_eye;
		vec3 norm = getNormal(pos);
        vec3 ref = reflect(dir, norm);

		if (material == M_FLOOR)
		{
			col = vec3(checkersGradBox(pos.xz * 5.0) * 0.5)  + 0.3;
		}
		else { col = materialColors[material]; }
		
		float occ = calcAmbientOcclusio(pos, norm);
		const vec3 lightPos = normalize(vec3(-0.4, 0.7, -0.6));
		vec3 hal = normalize(lightPos - dir);
		float ambient = clamp(0.5 + 0.5 * norm.y, 0.0, 1.0);
		float diffuse = clamp(dot(norm, lightPos), 0.0, 1.0);
		float bac = clamp(dot(norm, normalize(vec3(-lightPos.x, 0.0,-lightPos.z))), 0.0, 1.0) * clamp(1.0 - pos.y, 0.0, 1.0);
		vec3 dom = vec3(smoothstep(-0.1, 0.1, ref.y));
		float fre = pow(clamp(1.0+dot(norm, dir), 0.0, 1.0), 2.0);

    	diffuse *=  calcSoftshadow(pos, lightPos, 0.02, 2.5, 12.0);
       	dom *= 		calcSoftshadow(pos, ref, 0.02, 2.5, 12.0);

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

    	col = mix(col, vec3(0.8,0.9,1.0), 1.0-exp(-fogDist*pow(dist, 3)));
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

