extern vec2 size;
extern vec2 pos;
extern float eventH;
extern float escapeR;
extern vec3 holeColor;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec2 pos = pos/size;
	float eventH = eventH/size.x;
	float escapeR = escapeR/size.x;

	if(distance(texture_coords.xy,pos.xy) < eventH) {
		return vec4(holeColor.rgb,0);
	} else if(distance(texture_coords.xy,pos.xy) <= escapeR+eventH) { //magic
		vec2 guide = vec2(pos.xy-texture_coords.xy);
		
		float e = 1.0-((float(length(guide)) - float(eventH))/float(escapeR));
		
		return Texel(texture,vec2(float(texture_coords.x) + float(guide.x)*float(e),float(texture_coords.y) + float(guide.y)*float(e)));

		//return vec4(1,0,0,1);
	}

	return Texel(texture,texture_coords.xy).rgba;
}
