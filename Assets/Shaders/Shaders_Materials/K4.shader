Shader "Unlit/K4"
{
    Properties
    {
        _Segments ("Segments", Range(2, 20)) = 6           
        _Rotation ("Rotation", Float) = 0                  
        _Zoom ("Zoom", Float) = 1                          
        _Brightness ("Brightness", Float) = 1              
        _Glassiness ("Glassiness", Range(0, 5)) = 1        
        _GlowStrength ("Glow Strength", Range(0, 5)) = 1   
        _Speed ("Block Movement Speed", Float) = 1         
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float mirror(float v) {
                return abs(frac(v * 0.5) * 2.0 - 1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y;

                // UV transformaciones
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;
                uv = float2(mirror(uv.x), mirror(uv.y));

                float r = length(uv);
                float angle = atan2(uv.y, uv.x) + _Rotation;

                float segmentAngle = 3.14159265 / _Segments;
                angle = fmod(angle, 2.0 * segmentAngle);
                angle = abs(angle - segmentAngle);

                float2 mirroredUV = float2(cos(angle), sin(angle)) * r;

                // Movimiento animado en diagonal
                float2 animatedUV = mirroredUV + t * _Speed * float2(0.3, 0.7);

                // Patrón de cubos (tipo checker)
                float2 blockCoord = floor(animatedUV * 8.0);
                float checker = fmod(blockCoord.x + blockCoord.y, 2.0);
                float val = checker;

                // Glow desde el centro
                float glow = exp(-r * _GlowStrength * 2.0);
                val = saturate(val + glow * 0.8);

                // Glassiness
                float gloss = pow(val, _Glassiness * 2.5 + 0.5);

                // Escala de grises
                float gray = gloss * _Brightness;

                return float4(gray, gray, gray, 1);
            }
            ENDCG
        }
    }
}
