shader_type canvas_item;

uniform sampler2D screen_tex: hint_screen_texture;

void fragment() {
	if(UV.x <= 0.5){
		COLOR = texture(screen_tex, UV * vec2(0.5, 1.0));
	} else {
		COLOR = texture(screen_tex, UV * vec2(0.5, 1.0) + vec2(0.5, 0.0));
	}
}
