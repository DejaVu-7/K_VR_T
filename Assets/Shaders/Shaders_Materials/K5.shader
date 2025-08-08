Shader "Unlit/K5"
{
    Properties
    {
        _Segments ("Symmetry Segments", Range(2, 20)) = 6
        _Rotation ("Rotation", Float) = 0
        _Zoom ("Zoom", Float) = 1
        _Brightness ("Brightness", Float) = 1
        _GlowStrength ("Glow Strength", Range(0, 5)) = 1
        _Speed ("Movement Speed", Float) = 1
        _EdgeThreshold ("Edge Sharpness", Range(0.0, 1.0)) = 0.5
        _PatternScale ("Pattern Scale", Float) = 20
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

            #ifndef UNITY_PI
            #define UNITY_PI 3.14159265359
            #endif

            float _Segments;
            float _Rotation;
            float _Zoom;
            float _Brightness;
            float _GlowStrength;
            float _Speed;
            float _EdgeThreshold;
            float _PatternScale;

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

            fixed4 frag(v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;

                // Centrar y aplicar zoom
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;

                // Coordenadas polares
                float r = length(uv);
                float angle = atan2(uv.y, uv.x) + _Rotation + t * 0.2;

                // Simetría caleidoscópica
                float segAngle = (UNITY_PI * 2.0) / _Segments;
                angle = fmod(angle, segAngle);
                angle = abs(angle - segAngle * 0.5);

                float2 kaleidoUV = float2(cos(angle), sin(angle)) * r;

                // Movimiento más rápido y definido
                kaleidoUV += sin(t + kaleidoUV.yx * 4.0) * 0.15;

                // Patrón más denso
                float pattern = sin(kaleidoUV.x * _PatternScale + t) * sin(kaleidoUV.y * _PatternScale + t);

                // Forzar contraste para bordes nítidos
                float val = smoothstep(_EdgeThreshold, 1.0, abs(pattern));

                // Glow desde el centro, controlado
                float glow = exp(-r * _GlowStrength) * 0.5;
                val = saturate(val + glow);

                // Escala de grises
                float gray = val * _Brightness;

                return float4(gray, gray, gray, 1.0);
            }
            ENDCG
        }
    }
}
