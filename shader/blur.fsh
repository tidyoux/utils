#ifdef GL_ES
    precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 resolution;

void main(void)
{
    vec3 col = vec3(0);
    vec2 unit = 1.0 / resolution.xy;
    vec2 unit2 = 2.0 * unit;

    col += texture2D(CC_Texture0, v_texCoord).rgb * 2.0;
    
    col += texture2D(CC_Texture0, v_texCoord + vec2(-unit.x, 0)).rgb * 2.0;
    col += texture2D(CC_Texture0, v_texCoord + vec2(0, unit.y)).rgb * 2.0;
    col += texture2D(CC_Texture0, v_texCoord + vec2(unit.x, 0)).rgb * 2.0;
    col += texture2D(CC_Texture0, v_texCoord + vec2(0, -unit.y)).rgb * 2.0;
    
    col += texture2D(CC_Texture0, v_texCoord + vec2(-unit2.x, 0)).rgb;
    col += texture2D(CC_Texture0, v_texCoord + vec2(0, unit2.y)).rgb;
    col += texture2D(CC_Texture0, v_texCoord + vec2(unit2.x, 0)).rgb;
    col += texture2D(CC_Texture0, v_texCoord + vec2(0, -unit2.y)).rgb;

    col *= 0.07;
	
	gl_FragColor = vec4(col, 1.0) * v_fragmentColor;
}
