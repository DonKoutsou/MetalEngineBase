shader_type canvas_item;

uniform sampler2D palette_texture : filter_nearest, repeat_disable;

uniform int palette_index : hint_range(0, 15) = 1;
uniform float color_T = 0.1;

void fragment() {
	vec4 Ship = texture(TEXTURE, UV);
	ivec2 texS = textureSize(palette_texture, 0);
	for (int i = 0; i < texS.x; i++) {
        // Sample the center of each palette pixel.
        float x = (float(i) + 0.5) / float(texS.x);

        vec3 original_color = texture(palette_texture,vec2(x, 0.5 / float(texS.y))).rgb;

        if (distance(Ship.rgb, original_color) <= color_T) {
            float y = (float(palette_index) + 0.5) / float(texS.y);

            vec3 replacement_color = texture(palette_texture,vec2(x, y)).rgb;
			
			Ship = vec4(replacement_color, Ship.a);
            break;
        }
    }

	COLOR = Ship;
}
