//smooth min/max
float2 smin(float2 a, float2 b, float k){
  float h = clamp(0.5 + 0.5 * (b.x - a.x) / k, 0.0, 1.0);
  float d = lerp(b.x, a.x, h) - k * h * (1.0 - h);
  // float index = (a.x < b.x) ? a.y : b.y;//lerp(b.y, a.y, h);
  float index = lerp(b.y, a.y, h);
  return float2(d, index);
}

float2 smax(float2 a, float2 b, float k){
  float h = clamp(0.5 - 0.5 * (b.x - a.x) / k, 0.0, 1.0);
  float d = lerp(b.x, a.x, h) + k * h * (1.0 - h);
  float index = lerp(b.y, a.y, h);
  return float2(d, index);
}

// IQ's polynomial-based smooth minimum function.
float smin(float a, float b, float k ){
    float h = clamp(.5 + .5*(b - a)/k, 0., 1.);
    return lerp(b, a, h) - k*h*(1. - h);
}

// Commutative smooth minimum function. Provided by Tomkh and taken from
// Alex Evans's (aka Statix) talk:
// http://media.lolrus.mediamolecule.com/AlexEvans_SIGGRAPH-2015.pdf
// Credited to Dave Smith @media molecule.
float smin2(float a, float b, float r)
{
   float f = max(0., 1. - abs(b - a)/r);
   return min(a, b) - r*.25*f*f;
}

// IQ's exponential-based smooth minimum function. Unlike the polynomial-based
// smooth minimum, this one is associative and commutative.
float sminExp(float a, float b, float k)
{
    float res = exp(-k*a) + exp(-k*b);
    return -log(res)/k;
}
