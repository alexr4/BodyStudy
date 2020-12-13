float2 sdSphere(float3 p, float r, float index){
    return float2(length(p) - r, index);
}

float2 sdCapsule(float3 p, float3 a, float3 b, float r, float index){
  float3 ab = b-a;
  float3 ap = p-a;

  float t = dot(ab, ap) / dot(ab, ab); //project ray on the line between the two sphere of teh capsule to get the distance
  t = clamp(t, 0.0, 1.0);

  float3 c = a + t * ab; // get the ray a to the ab
  return float2(length(p-c) - r, index); // get the distance between p and the c
}

float2 sdTorus(float3 p, float2 r, float index){
  float x = length(p.xz) - r.x;
  return float2(length(float2(x, p.y)) - r.y, index);
}

float2 sdBox(float3 p, float3 s, float index){
  float3 d = abs(p) -s;

  return float2(length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0), //remove this line for an only partially signed sdf
              index);
}

float2 sdCylinder(float3 p, float3 a, float3 b, float r, float index){
  float3 ab = b-a;
  float3 ap = p-a;

  float t = dot(ab, ap) / dot(ab, ab); //project ray on the line between the two sphere of teh capsule to get the distance
  //t = clamp(t, 0.0, 1.0);

  float3 c = a + t * ab; // get the ray a to the ab

  float x = length(p-c) - r; // get the distance between p and the c
  float y = (abs(t - 0.5) - 0.5) * length(ab);
  float e = length(max(float2(x, y), 0.0));
  float i = min(max(x, y), 0.0);
  return float2(e + i, index);
}

float2 sdRoundBox(float3 p, float3 s, float r, float index){
  float3 d = abs(p) -s;

  return float2(length(max(d, 0.0)) - r + min(max(d.x, max(d.y, d.z)), 0.0), //remove this line for an only partially signed sdf
              index);
}

float dot2( in float2 v ) { return dot(v,v);}
float2 sdCone(float3 p, float h, float r1, float r2, float index){
    float2 q = float2( length(p.xz), p.y );

    float2 k1 = float2(r2,h);
    float2 k2 = float2(r2-r1,2.0*h);
    float2 ca = float2(q.x-min(q.x,(q.y < 0.0)?r1:r2), abs(q.y)-h);
    float2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return float2(s*sqrt(min(dot2(ca),dot2(cb))), index);
}

float2 sdSegment( float3 a, float3 b, float3 p )
{
	float3 pa = p - a;
	float3 ba = b - a;
	float t = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return float2( length( pa - ba*t ), t );
}

float2 sdPlane( float3 p, float4 n, float index )
{
  // n must be normalized
  return float2(dot(p,n.xyz) + n.w, index);
}

/*QUADRATIC BEZIER*/
float2 sdBezier(float3 A, float3 B, float3 C, float3 pos)
{    
    float3 a = B - A;
    float3 b = A - 2.0*B + C;
    float3 c = a * 2.0;
    float3 d = A - pos;

    float kk = 1.0 / dot(b,b);
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);      

    float2 res;

    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx - 3.0*ky) + kz;
    float h = q*q + 4.0*p3;

    if(h >= 0.0) 
    { 
        h = sqrt(h);
        float2 x = (float2(h, -h) - q) / 2.0;
        float2 uv = sign(x)*pow(abs(x), float2(1.0/3.0, 1.0/3.0));
        float t = uv.x + uv.y - kx;
        t = clamp( t, 0.0, 1.0 );

        // 1 root
        float3 qos = d + (c + b*t)*t;
        res = float2(length(qos), t);
    }
    else
    {
        float z = sqrt(-p);
        float v = acos( q/(p*z*2.0) ) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        float3 t = float3(m + m, -n - m, n - m) * z - kx;
        t = clamp( t, 0.0, 1.0 );

        // 3 roots
        float3 qos = d + (c + b*t.x)*t.x;
        float dis = dot(qos,qos);
        
        res = float2(dis,t.x);

        qos = d + (c + b*t.y)*t.y;
        dis = dot(qos,qos);
        if( dis<res.x ) res = float2(dis,t.y );

        qos = d + (c + b*t.z)*t.z;
        dis = dot(qos,qos);
        if( dis<res.x ) res = float2(dis,t.z );

        res.x = sqrt( res.x );
    }
    
    return res;
}