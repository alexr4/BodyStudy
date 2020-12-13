const float4x4 m4x4identity = float4x4(
	1.0, 0.0, 0.0, 0.0,
	0.0, 1.0, 0.0, 0.0,
	0.0, 0.0, 1.0, 0.0,
	0.0, 0.0, 0.0, 1.0);

// Construct a rotation matrix that rotates around the provided axis, sourced from:
// https://gist.github.com/keijiro/ee439d5e7388f3aafc5296005c8c3f33
float3x3 AngleAxis3x3(float angle, float3 axis)
{
    float c, s;
    sincos(angle, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    // return float3x3(
    //     t * x * x + c, t * x * y - s * z, t * x * z + s * y,
    //     t * x * y + s * z, t * y * y + c, t * y * z - s * x,
    //     t * x * z - s * y, t * y * z + s * x, t * z * z + c
    //     );
    return float3x3(
        t * x * x + c, t * x * y - s * z, t * x * z + s * y,
        t * x * y + s * z, t * y * y + c, t * y * z - s * x,
        t * x * z - s * y, t * y * z + s * x, t * z * z + c
        );
}

float4x4 AngleAxis4x4(float angle, float3 axis)
{
    float c, s;
    sincos(angle, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float4x4(
        t * x * x + c, t * x * y - s * z, t * x * z + s * y, 0,
        t * x * y + s * z, t * y * y + c, t * y * z - s * x, 0,
        t * x * z - s * y, t * y * z + s * x, t * z * z + c, 0,
        0, 0, 0, 1
        );
}

float4x4 quaternion_m(float4 q) {
	float xx = q.x * q.x * 2.0;
	float yy = q.y * q.y * 2.0;
	float zz = q.z * q.z * 2.0;
	float xy = q.x * q.y * 2.0;
	float yz = q.y * q.z * 2.0;
	float zx = q.z * q.x * 2.0;
	float wx = q.w * q.x * 2.0;
	float wy = q.w * q.y * 2.0;
	float wz = q.w * q.z * 2.0;

	float4x4 m = m4x4identity;
	m[0][0] = 1.0 - yy - zz;
	m[0][1] = xy - wz;
	m[0][2] = zx + wy;
	m[1][0] = xy + wz;
	m[1][1] = 1.0 - zz - xx;
	m[1][2] = yz - wx;
	m[2][0] = zx - wy;
	m[2][1] = yz + wx;
	m[2][2] = 1.0 - xx - yy;
	return m;
}

float4 qmul(float4 q1, float4 q2) {
	return float4(q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz), q1.w * q2.w + dot(-q1.xyz, q2.xyz));
}

float4 qrot(float3 axis, float d) {
	const float rad = d;// * 3.14159265359 * 0.5 / 180.0;
	float s, c;
	sincos(rad, s, c);
	return float4(normalize(axis) * s, c);
}

float4x4 rotate_m(float3 euler) {
	float4 qx = qrot(float3(1.0, 0.0, 0.0), euler.x);
	float4 qy = qrot(float3(0.0, 1.0, 0.0), euler.y);
	float4 qz = qrot(float3(0.0, 0.0, 1.0), euler.z);

	float4 q = qmul(qmul(qy, qx), qz);
	return quaternion_m(q);
}