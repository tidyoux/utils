#ifdef GL_ES
    precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;


void main(void)
{
    int range = 10;
    vec2 unit = vec2(0.001, 0.001);

    int count = 0;
    for (int i = -range; i <= range; i++)
    {
        for (int j = -range; j <= range; j++)
        {
            float a = texture2D(CC_Texture0, v_texCoord + vec2(unit.x * float(i), unit.y * float(j))).a;
            if (a > 0.01)
            {
                count++;
            }
        }
    }

    vec4 col = vec4(0);
    int base = range * 2 + 1;
    base *= base;
    if (0 < count && count < base * 2 / 3)
    {
        col = vec4(0, 1.0, 0, max(float(count) / float(base), 0.5));
    }
    else
    {
        col = texture2D(CC_Texture0, v_texCoord);
    }

	gl_FragColor = col * v_fragmentColor;
}
