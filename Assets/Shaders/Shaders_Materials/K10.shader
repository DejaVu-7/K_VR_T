Shader "Unlit/K10"
{
    Properties
    {
        _Segments ("Symmetry Segments", Range(2, 20)) = 6
        _Rotation ("Rotation", Float) = 0
        _Zoom ("Zoom", Float) = 1
        _Brightness ("Brightness", Float) = 1
        _GlowStrength ("Glow Strength", Range(0, 5)) = 1
        _Speed ("Movement Speed", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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
            float _GlowStrength;
            float _Speed;

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float mirror(float v) {
                return abs(frac(v * 0.5) * 2.0 - 1.0);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;

                // Centrar y aplicar zoom
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;

                // Convertir a coordenadas polares
                float r = length(uv);
                float angle = atan2(uv.y, uv.x) + _Rotation + t * 0.2;

                // Simetría caleidoscópica
                float segAngle = UNITY_PI * 2.0 / _Segments;
                angle = fmod(angle, segAngle);
                angle = abs(angle - segAngle * 0.5);

                float2 kaleidoUV = float2(cos(angle), sin(angle)) * r;

                // Movimiento en la textura del patrón
                kaleidoUV += sin(t + kaleidoUV.yx * 3.0) * 0.2;

                // Patrón dinámico: ondas radiales en cuadrícula
                float pattern = sin(kaleidoUV.x * 10.0 + t) * sin(kaleidoUV.y * 10.0 + t);
                float val = saturate(pattern * 0.5 + 0.5);

                // Glow desde el centro
                float glow = exp(-r * _GlowStrength);
                val += glow;

                // Escala de grises (mismo valor en R, G, B)
                float gray = val * _Brightness;

                return float4(gray, gray, gray, 1.0);
            }
            ENDCG
        }
    }
}
