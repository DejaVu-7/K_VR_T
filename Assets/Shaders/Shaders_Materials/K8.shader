Shader "Unlit/K8"
{
    Properties
    {
        _Segments ("Symmetry Segments", Range(2, 20)) = 6
        _Rotation ("Rotation", Float) = 0
        _Zoom ("Zoom", Float) = 1
        _Brightness ("Brightness", Float) = 1
        _GlowStrength ("Glow Strength", Range(0, 5)) = 1
        _Speed ("Movement Speed", Float) = 1
        _EdgeThreshold ("Edge Sharpness", Range(0.0, 1.0)) = 0.6
        _PatternScale ("Pattern Scale", Float) = 25
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

                
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;

                
                float r = length(uv);
                float angle = atan2(uv.y, uv.x) + _Rotation + t * 0.3;

                
                float segAngle = UNITY_PI * 2.0 / _Segments;
                angle = fmod(angle, segAngle);
                angle = abs(angle - segAngle * 0.5);

                float2 kaleidoUV = float2(cos(angle), sin(angle)) * r;

                kaleidoUV += float2(
                    sin(t * 3.0 + kaleidoUV.y * 5.0) * 0.2,
                    cos(t * 2.0 + kaleidoUV.x * 7.0) * 0.2
                );

                
                float pattern = sin(kaleidoUV.x * _PatternScale + t * 2.0) 
                              * cos(kaleidoUV.y * _PatternScale * 1.3 - t * 1.5)
                              * sin(length(kaleidoUV) * _PatternScale * 0.8 - t);

                pattern = abs(pattern);

                
                float val = smoothstep(_EdgeThreshold, 1.0, pattern);

                
                float glow = exp(-r * _GlowStrength * 1.5) * 0.7;
                val = saturate(val + glow);

               
                float gray = val * _Brightness;

                return float4(gray, gray, gray, 1.0);
            }
            ENDCG
        }
    }
}
