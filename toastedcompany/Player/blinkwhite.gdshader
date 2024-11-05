shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0;

void fragment() {
  vec4 color = texture(TEXTURE, UV);
  vec4 red_flash_color = vec4(1.0, 0.0, 0.0, 1.0);
  color.rgb = mix(color.rgb, red_flash_color.rgb, flash_modifier);
  COLOR = color;
}