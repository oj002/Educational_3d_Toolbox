//////////////////////////////////////////////////////////////////////
//                                                                  //
//          Functions thanks to http://mercury.sexy/hg_sdf          //
//                                                                  //
//////////////////////////////////////////////////////////////////////
/////////////////////////////////////
//                                 //
//          Helper/Macros          //
//                                 //
/////////////////////////////////////
#define PI 3.14159265
#define TAU (2*PI)
#define saturate(x) clamp(x, 0, 1)
#define PHI = (sqrt(5)*0.5 + 0.5);

float vmax(vec2 v) {
	return max(v.x, v.y);
}
float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}
float vmax(vec4 v) {
	return max(max(v.x, v.y), max(v.z, v.w));
}
float vmin(vec2 v) {
	return min(v.x, v.y);
}
float vmin(vec3 v) {
	return min(min(v.x, v.y), v.z);
}
float vmin(vec4 v) {
	return min(min(v.x, v.y), min(v.z, v.w));
}
float sgn(float x) {
	return (x<0)?-1:1;
}
vec2 sgn(vec2 v) {
	return vec2((v.x<0)?-1:1, (v.y<0)?-1:1);
}
float length2(vec2 v) {
	return sqrt( v.x*v.x + v.y*v.y );
}
float length6(vec2 v) {
	v = v*v*v; v = v*v;
	return pow( v.x + v.y, 1.0/6.0 );
}
float length8(vec2 v) {
	v = v*v; v = v*v; v = v*v;
	return pow( v.x + v.y, 1.0/8.0 );
}

////////////////////////////////////
//                                //
//          No Width SDF          //
//                                //
////////////////////////////////////
// Distance to line segment between <a> and <b>
float sdLineSegment(vec3 p, vec3 a, vec3 b) {
	vec3 ab = b - a;
	float t = saturate(dot(p - a, ab) / dot(ab, ab));
	return length((ab*t + a) - p);
}
float sdCircle(vec3 p, float r) {
	float l = length(p.xz) - r;
	return length(vec2(p.y, l));
}
////////////////////////////////////
//                                //
//          No Depth SDF          //
//                                //
////////////////////////////////////
float sdDisc(vec3 p, float r) {
	float l = length(p.xz) - r;
	return l < 0 ? abs(p.y) : length(vec2(p.y, l));
}
//////////////////////////////////////
//                                  //
//          Primitives SDF          //
//                                  //
//////////////////////////////////////
float sdSphere(vec3 p, float r) {
	return length(p) - r;
}
float sdEllipsoid(vec3 p, vec3 r) {
    return (length( p/r ) - 1.0) * vmin(r);
}

float sdYPlane(vec3 p) {
    return p.y + 1.0;
}
float sdYPlane(vec3 p, float h) {
    return p.y - h;
}

float sdBoxCheap(vec3 p, vec3 b) {
    return vmax(abs(p) - b);
}
float sdBox(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

// Endless box
float sdBox2Cheap(vec2 p, vec2 b) {
    return vmax(abs(p) - b);
}
float sdBox2(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
	return length(max(d, vec2(0))) + vmax(min(d, vec2(0)));
}

// Endless "corner"
float sdCorner(vec2 p) {
    return length(max(p, vec2(0))) + vmax(min(p, vec2(0)));
}

float sdCylinder(vec3 p, vec2 size) {
	return max(length(p.xz) - size.x, abs(p.y) - size.y);
}
float sdCylinder6(vec3 p, vec2 size)
{
    return max(length6(p.xz) - size.x, abs(p.y) - size.y);
}

// A Cylinder with round caps on both sides
float sdCapsule(vec3 p, float r, float c) {
	return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
}
// between two end points <a> and <b> with radius r 
float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
	return sdLineSegment(p, a, b) - r;
}

float sdTorus(vec3 p, vec2 r)
{
  return length(vec2(length(p.xz) - r.x, p.y)) - r.y;
}
float sdTorus82(vec3 p, vec2 r)
{
  vec2 q = vec2(length2(p.xz) - r.x, p.y);
  return length8(q) - r.y;
}
float sdTorus88(vec3 p, vec2 r)
{
  vec2 q = vec2(length8(p.xz) - r.x, p.y);
  return length8(q) - r.y;
}
float sdCone(vec3 p, float radius, float height) {
	vec2 q = vec2(length(p.xz), p.y);
	vec2 tip = q - vec2(0, height);
	vec2 mantleDir = normalize(vec2(height, radius));
	float mantle = dot(tip, mantleDir);
	float d = max(mantle, -q.y);
	float projected = dot(tip, vec2(mantleDir.y, -mantleDir.x));
	// distance to tip
	if ((q.y > height) && (projected < 0)) {
		d = max(d, length(tip));
	}
	// distance to base ring
	if ((q.x > radius) && (projected > length(vec2(height, radius)))) {
		d = max(d, length(q - vec2(radius, 0)));
	}
	return d;
}
float sdCone(vec3 p, vec3 c) {
    vec2 q = vec2( length(p.xz), p.y );
    float d1 = -q.y-c.z;
    float d2 = max( dot(q,c.xy), q.y);
    return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.);
}
float sdConeSection(vec3 p, float h, vec2 r) {
    float d1 = -p.y - h;
    float q = p.y - h;
    float si = 0.5*(r.x-r.y)/h;
    float d2 = max( sqrt( dot(p.xz,p.xz)*(1.0-si*si)) + q*si - r.y, q );
    return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.0);
}

//////////////////////////////////////
//                                  //
//          Primitives UDF          //
//                                  //
//////////////////////////////////////
float UD_Box(vec3 p, vec3 size)
{
    return length(max(abs(p) - size, 0.0));
}
float UD_RoundBox(vec3 p, vec3 size, float r)
{
    return length(max(abs(p) - size, 0.0)) - r;
}
////////////////////////////////
//                            //
//          Fractals          //
//                            //
////////////////////////////////
float sdMandelBulb(vec3 p, float Power, int Iterations, float Bailout)
{
	vec3 z = p;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < Iterations; ++i) {
		r = length(z);
		if (r>Bailout) break;
		
		// convert to polar coordinates
		/*float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);*/
		float theta = asin( z.z/r );
		float phi = atan( z.y,z.x );
		dr =  pow( r, Power-1.0)*Power*dr + 1.0;
		
		// scale and rotate the point
		float zr = pow( r,Power);
		theta = theta*Power;
		phi = phi*Power;
		
		// convert back to cartesian coordinates
		z = zr*vec3( cos(theta)*cos(phi), cos(theta)*sin(phi), sin(theta) );
		//z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=p;
	}
	return 0.5*log(r)*r/dr;
}
////////////////////////////////////////////
//                                        //
//          Space Manipulators            //
//                                        //
////////////////////////////////////////////
void spR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}
void spR45(inout vec2 p) {
	p = (p + vec2(p.y, -p.x))*sqrt(0.5);
}
mat3 spRX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}
mat3 spRY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}
mat3 spRZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}
vec3 spRepeat(vec3 p, vec3 c)
{
    return mod(p,c)-0.5*c;
}
// Repeat space along one axis. Use like this to repeat along the x axis:
// <float cell = pMod1(p.x,5);> - using the return value is optional.
float spMod1(inout float p, float size) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	return c;
}
// Same, but mirror every second cell so they match at the boundaries
float spModMirror1(inout float p, float size) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p + halfsize,size) - halfsize;
	p *= mod(c, 2.0)*2 - 1;
	return c;
}
// Repeat the domain only in positive direction. Everything in the negative half-space is unchanged.
float spModSingle1(inout float p, float size) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	if (p >= 0)
		p = mod(p + halfsize, size) - halfsize;
	return c;
}
// Repeat only a few times: from indices <start> to <stop> (similar to above, but more flexible)
float spModInterval1(inout float p, float size, float start, float stop) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p+halfsize, size) - halfsize;
	if (c > stop) { //yes, this might not be the best thing numerically.
		p += size*(c - stop);
		c = stop;
	}
	if (c <start) {
		p += size*(c - start);
		c = start;
	}
	return c;
}
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float spModPolar(inout vec2 p, float repetitions) {
	float angle = 2*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2)) c = abs(c);
	return c;
}
// Repeat in two dimensions
vec2 spMod2(inout vec2 p, vec2 size) {
	vec2 c = floor((p + size*0.5)/size);
	p = mod(p + size*0.5,size) - size*0.5;
	return c;
}
// Same, but mirror every second cell so all boundaries match
vec2 spModMirror2(inout vec2 p, vec2 size) {
	vec2 halfsize = size*0.5;
	vec2 c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	p *= mod(c,vec2(2))*2 - vec2(1);
	return c;
}

// Same, but mirror every second cell at the diagonal as well
vec2 spModGrid2(inout vec2 p, vec2 size) {
	vec2 c = floor((p + size*0.5)/size);
	p = mod(p + size*0.5, size) - size*0.5;
	p *= mod(c,vec2(2))*2 - vec2(1);
	p -= size/2;
	if (p.x > p.y) p.xy = p.yx;
	return floor(c/2);
}
// Repeat in three dimensions
vec3 spMod3(inout vec3 p, vec3 size) {
	vec3 c = floor((p + size*0.5)/size);
	p = mod(p + size*0.5, size) - size*0.5;
	return c;
}
// Mirror at an axis-aligned plane which is at a specified distance <dist> from the origin.
float spMirror (inout float p, float dist) {
	float s = sgn(p);
	p = abs(p)-dist;
	return s;
}
// Mirror in both dimensions and at the diagonal, yielding one eighth of the space.
// translate by dist before mirroring.
vec2 spMirrorOctant (inout vec2 p, vec2 dist) {
	vec2 s = sgn(p);
	spMirror(p.x, dist.x);
	spMirror(p.y, dist.y);
	if (p.y > p.x)
		p.xy = p.yx;
	return s;
}
// Reflect space at a plane
float spReflect(inout vec3 p, vec3 planeNormal, float offset) {
	float t = dot(p, planeNormal)+offset;
	if (t < 0) {
		p = p - (2*t)*planeNormal;
	}
	return sgn(t);
}
vec3 spTwist(vec3 p)
{
    float  c = cos(10.0*p.y+10.0);
    float  s = sin(10.0*p.y+10.0);
    mat2   m = mat2(c,-s,s,c);
    return vec3(m*p.xz,p.y);
}
//////////////////////////////////////////////////////
//                                                  //
//          Object Combination Operators            //
//                                                  //
//////////////////////////////////////////////////////
float opI(float d1, float d2) { return max(d1, d2); }
float opU(float d1, float d2) { return min(d1, d2); }
vec4 opU(vec4 d1, vec4 d2)
{
    return d1.x < d2.x ? d1 : d2;
}
float opD(float d1, float d2) { return max(d1, -d2); }

// The "Chamfer" flavour makes a 45-degree chamfered edge (the diagonal of a square of size <r>):
float opUChamfer(float a, float b, float r) {
	return min(min(a, b), (a - r + b)*sqrt(0.5));
}
// Intersection has to deal with what is normally the inside of the resulting object
// when using union, which we normally don't care about too much. Thus, intersection
// implementations sometimes differ from union implementations.
float opIChamfer(float a, float b, float r) {
	return max(max(a, b), (a + r + b)*sqrt(0.5));
}
// Difference can be built from Intersection or Union:
float opDChamfer (float a, float b, float r) {
	return opIChamfer(a, -b, r);
}

// The "Round" variant uses a quarter-circle to join the two objects smoothly:
float opURound(float a, float b, float r) {
	vec2 u = max(vec2(r - a,r - b), vec2(0));
	return max(r, min (a, b)) - length(u);
}
float opIRound(float a, float b, float r) {
	vec2 u = max(vec2(r + a,r + b), vec2(0));
	return min(-r, max (a, b)) + length(u);
}
float opDRound (float a, float b, float r) {
	return opIRound(a, -b, r);
}

// The "Columns" flavour makes n-1 circular columns at a 45 degree angle:
float opUColumns(float a, float b, float r, float n) {
	if ((a < r) && (b < r)) {
		vec2 p = vec2(a, b);
		float columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));
		spR45(p);
		p.x -= sqrt(2)/2*r;
		p.x += columnradius*sqrt(2);
		if (mod(n,2) == 1) {
			p.y += columnradius;
		}
		// At this point, we have turned 45 degrees and moved at a point on the
		// diagonal that we want to place the columns on.
		// Now, repeat the domain along this direction and place a circle.
		spMod1(p.y, columnradius*2);
		float result = length(p) - columnradius;
		result = min(result, p.x);
		result = min(result, a);
		return min(result, b);
	} else {
		return min(a, b);
	}
}
float opDColumns(float a, float b, float r, float n) {
	a = -a;
	float m = min(a, b);
	//avoid the expensive computation where not needed (produces discontinuity though)
	if ((a < r) && (b < r)) {
		vec2 p = vec2(a, b);
		float columnradius = r*sqrt(2)/n/2.0;
		columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));

		spR45(p);
		p.y += columnradius;
		p.x -= sqrt(2)/2*r;
		p.x += -columnradius*sqrt(2)/2;

		if (mod(n,2) == 1) {
			p.y += columnradius;
		}
		spMod1(p.y,columnradius*2);

		float result = -length(p) + columnradius;
		result = max(result, p.x);
		result = min(result, a);
		return -min(result, b);
	} else {
		return -m;
	}
}
float opIColumns(float a, float b, float r, float n) {
	return opDColumns(a,-b,r, n);
}

// The "Stairs" flavour produces n-1 steps of a staircase:
// much less stupid version by paniq
float opUStairs(float a, float b, float r, float n) {
	float s = r/n;
	float u = b-r;
	return min(min(a,b), 0.5 * (u + a + abs ((mod (u - a + s, 2 * s)) - s)));
}
// We can just call Union since stairs are symmetric.
float opIStairs(float a, float b, float r, float n) {
	return -opUStairs(-a, -b, r, n);
}
float opDStairs(float a, float b, float r, float n) {
	return -opUStairs(-a, b, r, n);
}

// Similar to opUnionRound, but more lipschitz-y at acute angles
// (and less so at 90 degrees). Useful when fudging around too much
// by MediaMolecule, from Alex Evans' siggraph slides
float opUSoft(float a, float b, float r) {
	float e = max(r - abs(a - b), 0);
	return min(a, b) - e*e*0.25/r;
}

// produces a cylindical pipe that runs along the intersection.
// No objects remain, only the pipe. This is not a boolean operator.
float opPipe(float a, float b, float r) {
	return length(vec2(a, b)) - r;
}
// first object gets a v-shaped engraving where it intersect the second
float opEngrave(float a, float b, float r) {
	return max(a, (a + r - abs(b))*sqrt(0.5));
}
// first object gets a capenter-style groove cut out
float opGroove(float a, float b, float ra, float rb) {
	return max(a, min(a + ra, rb - abs(b)));
}
// first object gets a capenter-style tongue attached
float opTongue(float a, float b, float ra, float rb) {
	return min(a, max(a - ra, abs(b) - rb));
}

