Shader "Unlit/K2_Gray"
{
    Properties
    {
        _Segments ("Segments", Range(2, 20)) = 6
        _Rotation ("Rotation", Float) = 0
        _Zoom ("Zoom", Float) = 1
        _Brightness ("Brightness", Float) = 1
        _Glassiness ("Glassiness", Range(0, 5)) = 1
        _GlowStrength ("Glow Strength", Range(0, 5)) = 1
        _Pattern ("Pattern Type", Range(0,2)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _Segments;
            float _Rotation;
            float _Zoom;
            float _Brightness;
            float _Glassiness;
            float _GlowStrength;
            float _Pattern;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float mirror(float v)
            {
                return abs(frac(v * 0.5) * 2.0 - 1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y;

                // Centrar y aplicar zoom
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;

                // Simetría espejo
                uv = float2(mirror(uv.x), mirror(uv.y));

                float r = length(uv);
                float angle = atan2(uv.y, uv.x) + _Rotation;

                // Segmentar
                float segmentAngle = 3.14159265 / _Segments;
                angle = fmod(angle, 2.0 * segmentAngle);
                angle = abs(angle - segmentAngle);

                // UV modificado
                float2 mirroredUV = float2(cos(angle), sin(angle)) * r;

                float val;

                // Patrón seleccionado
                if (_Pattern < 0.5) {
                    float2 grid = sin(mirroredUV * 10 + t);
                    val = (grid.x * grid.y) * 0.5 + 0.5;
                }
                else if (_Pattern < 1.5) {
                    val = sin(r * 20 - t * 4);
                    val = saturate(val * 0.5 + 0.5);
                }
                else {
                    float theta = atan2(mirroredUV.y, mirroredUV.x);
                    float rings = sin(r * 15 - t * 2);
                    float spikes = cos(theta * _Segments * 2);
                    val = rings * spikes;
                    val = saturate(val * 0.5 + 0.5);
                }

                // Glow
                float glow = exp(-r * _GlowStrength * 2.0);
                val = saturate(val + glow * 0.8);

                // Aplicar glassiness y brillo
                float gloss = pow(val, _Glassiness * 2.5 + 0.5);
                float gray = gloss * _Brightness;

                return float4(gray, gray, gray, 1);
            }
            ENDCG
        }
    }
}
