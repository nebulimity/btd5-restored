    shader_type canvas_item;

    uniform vec2 shadow_offset = vec2(2.0, 2.0); // Offset of the shadow
    uniform vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5); // Color and opacity of the shadow

    void fragment() {
        // Sample the original texture
        vec4 original_color = texture(TEXTURE, UV);

        // Sample the texture at the shadow offset
        vec4 shadow_sample = texture(TEXTURE, UV - shadow_offset * TEXTURE_PIXEL_SIZE);

        // Blend the shadow with the original color
        // If the shadow sample has alpha, draw the shadow color
        // Otherwise, draw the original color
        COLOR = mix(original_color, shadow_color, shadow_sample.a);
    }