Constants.blur_shader = love.graphics.newShader
[[
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords);
		
		float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
		float Quality = 4.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
		float Size = 0.0007; // BLUR SIZE (Radius)
		float Pi = 3.1415926535897932384626433832795;
		float c = 1;
		
		for( float d=0.0; d<Pi; d+=Pi/Directions)
		{
			for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
			{
				pixel += Texel(texture, texture_coords+vec2(cos(d),sin(d))*Size*i);
				c++;
			}
		}
		
		pixel = pixel/c;
		
		return pixel*color;
	}
]]