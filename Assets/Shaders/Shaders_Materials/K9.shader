Shader "Unlit/K9"
{
    Properties
    {
        _Segments ("Symmetry Segments", Range(3, 12)) = 6
        _Rotation ("Rotation", Float) = 0
        _Zoom ("Zoom", Float) = 1
        _Speed ("Animation Speed", Float) = 0.2
        _Brightness ("Brightness", Float) = 1
        _Softness ("Softness", Range(0.1, 1.0)) = 0.5
        _BaseColor ("Base Color", Color) = (0.8, 0.9, 0.85, 1)
        _AccentColor ("Accent Color", Color) = (0.6, 0.75, 0.8, 1)
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
            float _Speed;
            float _Brightness;
            float _Softness;
            float4 _BaseColor;
            float4 _AccentColor;

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

            // Función para suavizar el patrón
            float smoothPulse(float x, float speed, float time)
            {
                return 0.5 + 0.5 * sin(x * 6.283185 + time * speed);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2.0 - 1.0; // centrar UV [-1,1]
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time = _Time.y * _Speed;
                float2 uv = i.uv * _Zoom;

                // Cálculo polar
                float r = length(uv);
                float angle = atan2(uv.y, uv.x) + _Rotation + time * 0.1;

                // Simetría kaleidoscópica
                float segmentAngle = UNITY_TWO_PI / _Segments;
                angle = fmod(angle, segmentAngle);
                angle = abs(angle - segmentAngle * 0.5);

                float2 kaleidoUV = float2(cos(angle), sin(angle)) * r;

                // Patrones de ondas suaves
                float waveX = smoothPulse(kaleidoUV.x * 3.0, 1.0, time);
                float waveY = smoothPulse(kaleidoUV.y * 3.5, 1.2, time + 1.5);
                float waveR = smoothPulse(r * 4.0, 0.7, time + 3.0);

                // Combinación muy suave y armónica
                float combined = (waveX + waveY + waveR) / 3.0;

                // Suavizar bordes para evitar contraste duro
                combined = smoothstep(_Softness * 0.5, _Softness, combined);

                // Mezclar colores pastel
                float3 color = lerp(_BaseColor.rgb, _AccentColor.rgb, combined);

                // Aplicar brillo general
                color *= _Brightness;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
