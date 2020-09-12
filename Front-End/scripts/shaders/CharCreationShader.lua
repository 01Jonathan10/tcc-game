Constants.char_shader = love.graphics.newShader
[[
	extern vec4 hair_color;
	extern vec4 eye_color;
	extern vec4 skin_color;
	
	vec4 overlay(in float bright, in vec4 b, in float alpha){
		vec4 result = b;
		if (bright < 0.5){
			result.r = 2 * bright * b.r;
			result.g = 2 * bright * b.g;
			result.b = 2 * bright * b.b;
		}
		else
		{
			result.r = 1-2*(1-bright)*(1-b.r);
			result.g = 1-2*(1-bright)*(1-b.g);
			result.b = 1-2*(1-bright)*(1-b.b);
		}
		result.a = alpha;
		return result;
	}
	
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords );
		
		if (pixel.r == pixel.b && pixel.b == pixel.g){
			return pixel * color;
		}
		
		if (pixel.r != pixel.g && pixel.g == pixel.b){
			if (pixel.g == 0){
				float bright = pixel.r;
				pixel.r = skin_color.r + bright-1;
				pixel.g = skin_color.g + bright-1;
				pixel.b = skin_color.b + bright-1;
			} else {
				float bright = pixel.g;
				float red = pixel.r;
				pixel.r = (skin_color.r + red-1) + bright;
				pixel.g = (skin_color.g + red-1) + bright;
				pixel.b = (skin_color.b + red-1) + bright;
			}
		
		} else if (pixel.b > pixel.g && pixel.g == pixel.r) {
			float bright = pixel.b;
			pixel.r = bright * eye_color.r;
			pixel.g = bright * eye_color.g;
			pixel.b = bright * eye_color.b;
		} else if (pixel.g > pixel.b && pixel.b == pixel.r){
			float bright = pixel.g;
			pixel.r = bright * hair_color.r;
			pixel.g = bright * hair_color.g;
			pixel.b = bright * hair_color.b;
			return pixel * color;
		}
		return pixel * color;
	}
]]