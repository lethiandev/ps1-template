// Shader code migrated from:
// https://github.com/jmickle66666666/PSX-Dither-Shader
shader_type canvas_item;
render_mode unshaded, blend_disabled;

//uniform sampler2D screen_texture;
//uniform vec2 screen_size = vec2(320.0, 240.0);
uniform sampler2D pattern_texture;
uniform vec2 pattern_size = vec2(36.0, 4.0);
uniform float color_depth = 32.0;

//varying flat vec2 screen_texel;

float channel_error(float col, float col_min, float col_max) {
	float range = abs(col_min - col_max);
	float a_range = abs(col - col_min);
	return a_range / range;
}

float dithered_channel(float error, vec2 dither_uv, float dither_steps) {
	error = floor(error * dither_steps) / dither_steps;
	
	vec2 uv = vec2(error, 0.0);
	uv.x += dither_uv.x;
	uv.y = dither_uv.y;
	
	return texture(pattern_texture, uv).x;
}

vec4 rgb_to_yuv(vec4 rgba) {
	vec4 yuva;
	yuva.r = rgba.r * 0.2126 + 0.7152 * rgba.g + 0.0722 * rgba.b;
	yuva.g = (rgba.b - yuva.r) / 1.8556;
	yuva.b = (rgba.r - yuva.r) / 1.5748;
	yuva.a = rgba.a;

	// Adjust to work on GPU
	yuva.gb += 0.5;

	return yuva;
}

vec4 yuv_to_rgb(vec4 yuva) {
	yuva.gb -= 0.5;
	return vec4(
		yuva.r * 1.0 + yuva.g * 0.0 + yuva.b * 1.5748,
		yuva.r * 1.0 + yuva.g * -0.187324 + yuva.b * -0.468124,
		yuva.r * 1.0 + yuva.g * 1.8556 + yuva.b * 0.0,
		yuva.a
	);
}

void vertex() {
	//screen_texel = vec2(
	//	1.0 / screen_size.x,
	//	1.0 / screen_size.y
	//);
}

void fragment() {
	// sample the texture and convert to YUV color space
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 yuv = rgb_to_yuv(col);
	
	// Clamp the YUV color to specified color depth
	// (default: 32, 5 bits per channel, as per playstation hardware)
	vec4 col1 = floor(yuv * color_depth) / color_depth;
	vec4 col2 = ceil(yuv * color_depth) / color_depth;
	
	// Calculate dither texture UV based on the input texture
	float dither_size = pattern_size.y;
	float dither_steps = pattern_size.x / dither_size;
	
	vec2 dither_uv = UV;
	vec2 screen_texel = SCREEN_PIXEL_SIZE;
	dither_uv.x = mod(dither_uv.x, dither_size * screen_texel.x);
	dither_uv.x /= (dither_size * screen_texel.x);
	dither_uv.y = mod(dither_uv.y, dither_size * screen_texel.y);
	dither_uv.y /= (dither_size * screen_texel.y);
	dither_uv.x /= dither_steps;
	
	// Dither each channel individually
	yuv.x = mix(col1.x, col2.x, dithered_channel(channel_error(yuv.x, col1.x, col2.x), dither_uv, dither_steps));
	yuv.y = mix(col1.y, col2.y, dithered_channel(channel_error(yuv.y, col1.y, col2.y), dither_uv, dither_steps));
	yuv.z = mix(col1.z, col2.z, dithered_channel(channel_error(yuv.z, col1.z, col2.z), dither_uv, dither_steps));
	
	COLOR = yuv_to_rgb(yuv);
}
