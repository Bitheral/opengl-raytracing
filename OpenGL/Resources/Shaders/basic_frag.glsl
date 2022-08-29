#version 330 core

in vec3 Vertex;
in vec3 Normal;
in vec2 TexCoords;

uniform vec2 dimensions;
uniform vec3 rayOrigin;

uniform float radius;
uniform float time;
uniform float aR;

uniform sampler2D texture1;

uniform vec3 lightDir;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform vec3 spherePos;
uniform vec3 rayDirections[];

out vec4 FragColor;

vec3 worldSpace = vec3((TexCoords * 2.0f - 1.0f), 1);

vec3 circle(vec3 eye, vec3 dir) {
	float a = dot(dir, dir);
	float b = 2.0f * dot(eye, dir);
	float c = (dot(eye, eye) - radius * radius);

	float discriminant = (b * b - 4.0f * a * c);
	if (discriminant < 0.0001f)
		return vec3(0);

	float t0 = (-b - sqrt(discriminant)) / (2.0f * a);
	float t1 = (-b + sqrt(discriminant)) / (2.0f * a); // Second hit distance (currently unused)

	float closestT = 0;

	if(t1 < t0) closestT = t1;
	else if(t1 > t0) closestT = t0;
	else closestT = 0;

	vec3 hitPoint = (eye + spherePos) + dir * closestT;
	return hitPoint;
}

vec3 texturize(int mode, sampler2D textureColour, vec3 normal) {
	if(mode == 1) {
		vec2 uv = vec2(atan(normal.x, normal.z) / (2.0f * 3.1415965f) + 0.5f, asin(normal.y) / 3.1415965f + 0.5f);
		return texture(textureColour, uv).rgb;
	}
}

void main() {
	vec3 final = vec3(0);
	vec4 target = inverse(projection) * vec4(worldSpace.xyz, 1);
	vec3 rayDirection = vec3(inverse(view) * vec4(normalize(vec3(target) / target.w), 0));

	vec3 circleHit = circle(rayOrigin, rayDirection);

	vec3 normal = normalize(circleHit);

	vec3 aLightDir = normalize(lightDir);
	float lightIntensity = max(dot(normal, -lightDir), 0.0f); // == cos(angle)

	vec3 sphereColor = vec3(1,0,1);//texturize(1, texture1, normal);
	sphereColor *= lightIntensity;

	if(circle(rayOrigin, rayDirection) != vec3(0)) final = sphereColor;
	else final = mix(rayDirection, worldSpace, 0.5);

	FragColor = vec4(final, 1.0);
}