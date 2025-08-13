Shader "Unlit/K6"
{
    Properties
    {
        _Zoom ("Zoom", Float) = 1
        _Speed ("Chaos Speed", Float) = 1
        _Brightness ("Brightness", Float) = 1
        _Distort ("Distortion", Range(0,2)) = 0.8
        _NoiseStrength ("Noise Strength", Range(0,2)) = 1.0
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

            float _Zoom;
            float _Speed;
            float _Brightness;
            float _Distort;
            float _NoiseStrength;

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
            };

            
            float hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float a = hash21(i);
                float b = hash21(i + float2(1.0, 0.0));
                float c = hash21(i + float2(0.0, 1.0));
                float d = hash21(i + float2(1.0, 1.0));
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;

                
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;

                
                float distort = noise(uv * 2.0 + t) * _Distort;
                uv += distort * sin(uv.yx * 3.0 + t);

               
                float n = noise(uv * 3.0 + t * 0.5) * _NoiseStrength;

               
                float chaos = sin(uv.x * 8.0 + n * 6.0 + t * 2.0) * 
                              cos(uv.y * 8.0 - n * 6.0 - t * 1.5);

                
                float val = smoothstep(0.0, 0.5, chaos) - smoothstep(0.5, 1.0, chaos);

                float flicker = noise(uv * 10.0 + t * 5.0) * 0.5;

                
                float gray = saturate(val + flicker + n * 0.3) * _Brightness;

                return float4(gray, gray, gray, 1);
            }
            ENDCG
        }
    }
}
