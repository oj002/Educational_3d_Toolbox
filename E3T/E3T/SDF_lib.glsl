float length2(vec2 p)
{
	return sqrt( p.x*p.x + p.y*p.y );
}
float length6(vec2 p)
{
	p = p*p*p; p = p*p;
	return pow( p.x + p.y, 1.0/6.0 );
}
float length8(vec2 p)
{
	p = p*p; p = p*p; p = p*p;
	return pow( p.x + p.y, 1.0/8.0 );
}


//////////////////////
//  Primitives SDF  //
//////////////////////
float SD_Sphere(vec3 p, float r)
{
	return length(p) - r;
}
float SD_Ellipsoid(vec3 p, vec3 r)
{
    return (length( p/r ) - 1.0) * min(min(r.x,r.y),r.z);
}
float SD_Box(vec3 p, vec3 size)
{
	vec3 d = abs(p) - size;
    float insideDistance = min(max(d.x, max(d.y, d.z)), 0.0);
    float outsideDistance = length(max(d, 0.0));
    return insideDistance + outsideDistance;
}
float SD_Cylinder(vec3 p, vec2 size)
{
  vec2 d = abs(vec2(length(p.xz), p.y)) - size;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
float SD_HexPrism(vec3 p, vec2 size)
{
    vec3 q = abs(p);
    return max(q.z-size.y,max((q.x*0.866025+q.y*0.5),q.y)-size.x);
}
float SD_TriPrism(vec3 p, vec2 size)
{
    vec3 q = abs(p);
    return max(q.z-size.y,max(q.x*0.866025+p.y*0.5,-p.y)-size.x*0.5);
}
float SD_Octahedron(vec3 p, vec3 size) // size = { cos a, sin a }
{
    float d = 0.0;
    d = max( d, abs( dot(p, vec3( -size.x, size.y, 0 )) ));
    d = max( d, abs( dot(p, vec3(  size.x, size.y, 0 )) ));
    d = max( d, abs( dot(p, vec3(  0, size.y, size.x )) ));
    d = max( d, abs( dot(p, vec3(  0, size.y,-size.x )) ));
    float octa = d - size.z;
    return octa;
 }
float SD_Pyramid4(vec3 p, vec3 size) // size = { cos a, sin a, height }
{
    // Tetrahedron = Octahedron - Cube
    float box = SD_Box( p - vec3(0,-2.0*size.z,0), vec3(2.0*size.z) );
    return max(-box, SD_Octahedron(p, size));
 }
float SD_Capsule(vec3 p, vec3 a, vec3 b, float r)
{
	vec3 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h ) - r;
}
float SD_Cone(vec3 p, vec3 c)
{
    vec2 q = vec2( length(p.xz), p.y );
    float d1 = -q.y-c.z;
    float d2 = max( dot(q,c.xy), q.y);
    return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.);
}
float SD_ConeSection(vec3 p, float h, vec2 r)
{
    float d1 = -p.y - h;
    float q = p.y - h;
    float si = 0.5*(r.x-r.y)/h;
    float d2 = max( sqrt( dot(p.xz,p.xz)*(1.0-si*si)) + q*si - r.y, q );
    return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.0);
}
float SD_Torus(vec3 p, vec2 r)
{
  vec2 q = vec2(length(p.xz) - r.x, p.y);
  return length(q) - r.y;
}
float SD_Torus82(vec3 p, vec2 r)
{
  vec2 q = vec2(length2(p.xz) - r.x, p.y);
  return length8(q) - r.y;
}
float SD_Torus88(vec3 p, vec2 r)
{
  vec2 q = vec2(length8(p.xz) - r.x, p.y);
  return length8(q) - r.y;
}
float SD_Cylinder6(vec3 p, vec2 size)
{
    return max( length6(p.xz)-size.x, abs(p.y)-size.y );
}
float SD_yPlane(vec3 p, float h = -1)
{
    return p.y - h;
}
//////////////////////
//  Primitives UDF  //
//////////////////////
float UD_Box(vec3 p, vec3 size)
{
    return length(max(abs(p) - size, 0.0));
}
float UD_RoundBox(vec3 p, vec3 size, float r)
{
    return length(max(abs(p) - size, 0.0)) - r;
}

/////////////////
//  Operators  //
/////////////////
mat3 rotateX(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}
mat3 rotateY(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}
mat3 rotateZ(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}
vec3 repeat(vec3 p, vec3 c)
{
    return mod(p,c)-0.5*c;
}
vec3 twist(vec3 p)
{
    float  c = cos(10.0*p.y+10.0);
    float  s = sin(10.0*p.y+10.0);
    mat2   m = mat2(c,-s,s,c);
    return vec3(m*p.xz,p.y);
}
/////////////////
//  Operators  //
/////////////////
float opI(float d1, float d2) { return max(d1, d2); }
float opU(float d1, float d2) { return min(d1, d2); }
float opU(float d1, int m1, float d2, int m2, out int m)
{
    if(d1 < d2) 
    {
        m = m1;
        return d1;
    }
    else
    {
        m = m2;
        return d2;
    }
}
float opSU(float d1, float d2, float k = 32)
{
    return -log(max(0.0001, exp(-k * d1) + exp(-k * d2))) / k;
}
float opSU(float d1, int m1, float d2, int m2, out int m, float k = 32)
{
    m = (d1  < d2 ? m1 : m2);
    return -log(max(0.0001, exp(-k * d1) + exp(-k * d2))) / k;
}
float opD(float d1, float d2) { return max(d1, -d2); }

