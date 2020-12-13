/* QUAD */
float inQuad(in float value)
{ 
    return clamp(1.0 * value * value, 0, 1);
}

float outQuad(in float value)
{ 
    return clamp(-1.0 * value * (value - 2.0), 0, 1);
}

float inoutQuad(in float value){
    value *= 2.0;
    float inc = 1.0;
    float eased = 0.0;
    float stepper = step(1.0, value);
    eased += (0.5 * value * value) * (1.0 - stepper);
    value--;
    eased += (-0.5 * (value * (value - 2.0) - 1.0)) * stepper;
    return clamp(eased, 0.0, 1.0);
}

/* CUBIC */
float inCubic(in float value)
{ 
    return clamp(pow(value, 3.0), 0.0, 1.0);
}

float outCubic(in float value)
{ 
    value --;
    return clamp((pow(value, 3.0) + 1.0), 0.0, 1.0);
}

float inoutCubic(in float value)
{ 
    value /= 0.5;
    float stepper = step(1.0, value);
    float eased = clamp(0.5 * pow(value, 3.0), 0.0, 1.0) * (1.0 - stepper);
    value -= 2;
    eased += clamp(0.5 * (pow(value, 3.0) + 2.0), 0.0, 1.0) * stepper;
    return eased;
}

/*QUARTIC*/
float inQuartic(in float value){
    return clamp(pow(value, 4), 0,1);
}

float outQuartic(in float value){
    value = 1.0 - value;
    return clamp(-1.0 * (pow(value, 4.0) - 1.0), 0, 1);
}

float inoutQuartic(in float value){
    value /= 0.5;
    float stepper = step(1.0, value);
    float eased = clamp(0.5 * pow(value, 4.0), 0, 1) * (1.0 - stepper);
    value = 2.0 - value;
    eased += clamp(-0.5 * (pow(value, 4.0) - 2.0), 0, 1) * stepper;
    return eased;
}

/*QUINTIC*/
float inQuintic(in float value){
    return clamp(pow(value, 5.0), 0.0, 1.0);
}

float outQuintic(in float value){
    value = 1.0 - value;
    return clamp(-1.0 * pow(value, 5.0) + 1.0, 0.0, 1.0);
}

float inoutQuintic(in float value){
    value /= 0.5;
    float stepper = step(1.0, value);
    float eased = clamp(0.5 * pow(value, 5.0), 0.0, 1.0) * (1.0 - stepper);
    value = 2.0 - value;
    eased += clamp(-0.5 * (pow(value, 5.0) - 2.0), 0.0, 1.0) * stepper;
    return eased;
}

/* SIN */
float inSin(in float value){
    return clamp(-1.0 * cos(value * 3.1415926535897932384626433832795 * 0.5) + 1.0, 0.0, 1.0);
}

float outSin(in float value){
    return clamp(sin(value * 3.1415926535897932384626433832795 * 0.5), 0.0, 1.0);
}

float inoutSin(in float value){
    return clamp(-0.5 * (cos(value * 3.1415926535897932384626433832795) - 1.0 ), 0.0, 1.0);
}

/* Exponential */
float inExp(in float value){
    return clamp(pow(2.0, 10 * (value - 1.0)), 0.0, 1.0);
}

float outExp(in float value){
    return clamp(-pow(2.0, -10.0 * value) + 1.0, 0.0, 1.0);
}

float inoutExp(in float value){
    value /= 0.5;
    float stepper = step(1.0, value);
    float eased = clamp(0.5 * pow(2.0, 10.0 * (value - 1.0)), 0.0, 1.0) * (1.0 - stepper);
    value --;
    eased += clamp(0.5 * (-pow(2, -10 * value) + 2.0), 0.0, 1.0) * stepper;
    return eased;
}

/* Circular */
float inCirc(in float value){
    return clamp(-1.0 * (sqrt(1.0 - value * value) - 1.0), 0.0, 1.0);
}

float outCirc(in float value){
    value --;
    return clamp(sqrt(1.0 - value * value), 0.0, 1.0);
}

float inoutCirc(in float value){
    value /= 0.5;
    float stepper = step(1.0, value);
    float eased = clamp(-0.5 * (sqrt(1.0 - value * value) - 1.0), 0.0, 1.0) * (1.0 - stepper);
    value -= 2.0;
    eased += clamp(0.5 * (sqrt(1.0 - value * value) + 1.0), 0.0, 1.0) * stepper;
    return eased;
}

/*Elastic*/
float inElastic(in float value, float power){
    float c = -0.18;
    float p = pow(value, power); //min value = 2.0
    return p * sin((value * 3.1415926535897932384626433832795) / c);
}

float outElastic(in float value, float power){
    value = 1.0 - value;
    float c = -0.18;
    float p = pow(value, power); //min value = 2.0
    return 1.0 - (p * sin((value * 3.1415926535897932384626433832795) / c));
}

float inoutElastic(in float value, float power){
    value = (value * 2.0 - 1.0);
    float c = -0.18;
    float p = pow(abs(value), power); //min value = 2.0
    float stepper = 1.0 - step(0.0, value);
    return (1.0 * stepper) - p * sin((abs(value) * 3.1415926535897932384626433832795) / c);
}