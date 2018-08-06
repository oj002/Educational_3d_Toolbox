@import "SDF_lib.glsl"
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

@ImGui_uniform vec3 u_sphere ColorPicker3() 		= vec3(1.0, 0.0, 0.0); @Colors
//@ImGui_uniform vec3 u_box ColorPicker3() 			= vec3(0.0, 1.0, 0.0); @Colors
//@ImGui_uniform vec3 u_torus ColorPicker3() 			= vec3(0.0, 0.0, 1.0); @Colors
//@ImGui_uniform vec3 u_prisim ColorPicker3() 		= vec3(0.0, 1.0, 1.0); @Colors
//@ImGui_uniform vec3 u_cylinder ColorPicker3() 		= vec3(1.0, 0.0, 1.0); @Colors
//@ImGui_uniform vec3 u_cone ColorPicker3() 			= vec3(0.5, 1.0, 0.0); @Colors
//@ImGui_uniform vec3 u_pyramidCone ColorPicker3()	= vec3(0.0, 1.0, 0.5); @Colors

//@ImGui_uniform float u_exponent SliderFloat(0.0f, 8.0f) = 2.0;
//@ImGui_uniform int u_iterations SliderInt(1, 100) = 3;
@ImGui_uniform float maxDist SliderFloat(0.0f, 1000.0f) = 1000.0;
@ImGui_uniform float epsilon SliderFloat(0.0f, 0.01f) =  0.001;
@ImGui_uniform int maxStep SliderInt(1, 1000) = 100;
const float minDist = 0.0;
//const float maxDist = 20.0;
//const int maxStep = 100;
//const float epsilon = 0.001;
const float fogDist = 0.0;

@ImGui_uniform float u_width SliderFloat(0.0f, 50.0f) = 10.0;
@ImGui_uniform int u_polar SliderInt(1, 100) = 4.0;

vec4 sdScene(vec3 p)
{
	spMirrorOctant(p.xz, vec2(100));
	spModPolar(p.xz, float(3));
	spMirrorOctant(p.xz, vec2(40, 60));
	float plane = sdYPlane(p);
	p.y -= 14;

	spModPolar(p.xz, float(u_polar));
	spMirrorOctant(p.xz, vec2(70, 40));
	spMirrorOctant(p.xz, vec2(40, 60));
	p.x = -abs(p.x) + u_width;

	float c = spMod1(p.z, 20);

	float wall = sdBox2(p.xy, vec2(1, 15));

	p.z = abs(p.z) - 3;
	p.z = abs(p.z) + 2;

	
	float box = sdBox(p, vec3(3, 9, 4));
	p.y -= 9;
	float cylinder = sdCylinder(p.yxz, vec2(4, 3));

	p.y -= 6;
	spR(p.xy, 0.5);
	p.x -= 18;
	float roof = sdBox2(p.xy, vec2(20, 0.5));

	float window = min(box, cylinder);
	wall = opDColumns(wall, window, 1.0, 3);
	
	float building = min(wall, roof);
	float res = building;
	return opU(vec4(plane, vec3(-1)), vec4(res, u_sphere));

	/*float cylinder = sdCylinder(p.yxz, vec2(0.1, 0.3));
	float box = sdBox(p, vec3(0.1, 0.9, 0.4));
		
	return opU(Material(sdYPlane(p), M_FLOOR), Material(opCombine(box, cylinder, 0.02), u_sphere));
	*/
	
	//return vec4(sdMandelBulb(p, u_exponent, u_iterations, 5.0), u_sphere);
	
	/*float d = sdBox(p, vec3(1.0));
   	vec4 res = vec4( d, 1.0, 0.0, 0.0 );

	float s = 1.0;
	for( int m=0; m<u_iterations; m++ )
	{
		vec3 a = mod( p*s, 2.0 )-1.0;
		s *= 3.0;
		vec3 r = abs(1.0 - 3.0*abs(a));

		float da = max(r.x,r.y);
		float db = max(r.y,r.z);
		float dc = max(r.z,r.x);
		float c = (min(da,min(db,dc))-1.0)/s;

		if( c>d )
		{
			d = c;
			res = vec4( d, 0.2*da*db*dc, (1.0+float(m))/4.0, 0.0 );
		}
	}

	return res;*/

   	/*p.x = mod(p.x, 1.5 * 2.0) - 1.5;
    p.z = mod(p.z, 1.5 * 2.0) - 1.5;
	float d = sdBox(p,vec3(u_exponent));
    vec4 res = vec4(d, 1.0, 0.0, 0.0);

    float ani = smoothstep(-0.2, 0.2, -cos(0.5 * u_time));
	float off = 1.5 * sin(0.01 * u_time);
	const mat3 ma = mat3(0.60, 0.00,  0.80,
                      	 0.00, 1.00,  0.00,
                        -0.80, 0.00,  0.60);
    float s = 1.0;
    for (int m = 0; m < u_iterations; ++m)
    {
	
        p = mix(p, ma * (p + off), ani);
	   
        vec3 a = mod(p * s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));
        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        float c = (min(da,min(db,dc))-1.0)/s;

        if( c>d )
        {
          d = c;
          res = vec4(d, min(res.y,0.2*da*db*dc), (1.0+float(m))/4.0, 0.0);
        }
    }

    return res;*/
}
vec4 castRay(vec3 pos, vec3 dir)
{
	vec4 total = vec4(minDist,-2,-2,-2);
    for(int steps = 0; steps < maxStep; ++steps)
    {
	   	vec4 res = sdScene(pos + dir * total.x);
        if(res.x < epsilon*total.x || total.x > maxDist) break;
        total.x += res.x;
		total.yzw = res.yzw;
    }

    if(total.x>maxDist) total.yzw = vec3(-2);
    return total;
	/*int steps = 0;
	while (totalDist < maxDist)
    {
        float Dist = sdScene(dir * totalDist + pos, m);
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
    return normalize( e.xyy*sdScene(p + e.xyy).x + 
					  e.yyx*sdScene(p + e.yyx).x + 
					  e.yxy*sdScene(p + e.yxy).x + 
					  e.xxx*sdScene(p + e.xxx).x );
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
        float hr = 0.02 + 0.03 * float(i);
        vec3 aoPos =  norm * hr + p;
        float dd = sdScene(aoPos).x;
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
        float dist = sdScene(dir * totalDist + p).x;
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
        float dist = sdScene(dir * totalDist + p).x;
		dist = min(dist, k * dist / totalDist);
        totalDist += dist;
        if(dist < epsilon) return 0.0;
	}
    return dist;
}
vec3 render(vec3 dir)
{
    vec3 col = dir.y * 0.8 + vec3(0.7, 0.9, 1.0);
	vec4 res = castRay(u_eye, dir);
	float dist = res.x;
	vec3 material = res.yzw;

	if(material != vec3(-2))
	{
		vec3 pos = dir * dist + u_eye;
		vec3 norm = getNormal(pos);
        vec3 ref = reflect(dir, norm);

		if (material == vec3(-1))
		{
			col = vec3(checkersGradBox(pos.xz) * 0.5)  + 0.3;
		}
		else { col = material; }
		
		float occ = calcAmbientOcclusio(pos, norm);
		const vec3 lightPos = normalize(vec3(-0.4, 0.7, -0.6));
		vec3 hal = normalize(lightPos - dir);
		float ambient = clamp(0.5 + 0.5 * norm.y, 0.0, 1.0);
		float diffuse = clamp(dot(norm, lightPos), 0.0, 1.0);
		float bac = clamp(dot(norm, normalize(vec3(-lightPos.x, 0.0,-lightPos.z))), 0.0, 1.0) * clamp(1.0 - pos.y, 0.0, 1.0);
		vec3 dom = vec3(smoothstep(-0.1, 0.1, ref.y));
		float fre = pow(clamp(1.0+dot(norm, dir), 0.0, 1.0), 2.0);

    	//diffuse *=  calcSoftshadow(pos, lightPos, 0.2, 2.5, 12.0);
       	//dom *= 		calcSoftshadow(pos, ref, 0.2, 2.5, 12.0);

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

