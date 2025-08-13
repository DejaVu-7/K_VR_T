Shader "Unlit/K7"
{
    Properties
    {
        _Segments ("Symmetry Segments", Range(2, 20)) = 8
        _Rotation ("Rotation", Float) = 0
        _Zoom ("Zoom", Float) = 1
        _MainColor ("Base Color", Color) = (0.6, 0.8, 1, 1)
        _ChaosColor ("Chaos Color", Color) = (1, 0.5, 0.5, 1)
        _BlendChaos ("Chaos Blend", Range(0,1)) = 0.4
        _CalmSpeed ("Calm Rotation Speed", Float) = 0.2
        _ChaosSpeed ("Chaos Distort Speed", Float) = 2
        _DistortStrength ("Chaos Distort Strength", Range(0,1)) = 0.15
        _Brightness ("Brightness", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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

            float _Segments;
            float _Rotation;
            float _Zoom;
            float4 _MainColor;
            float4 _ChaosColor;
            float _BlendChaos;
            float _CalmSpeed;
            float _ChaosSpeed;
            float _DistortStrength;
            float _Brightness;
            float _TimeParameters;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2.0 - 1.0; 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time.y;

             
                float calmAngle = _Rotation + time * _CalmSpeed;

                float2 uv = i.uv * _Zoom;
                float r = length(uv);
                float theta = atan2(uv.y, uv.x) + calmAngle;

                
                float segmentAngle = UNITY_TWO_PI / _Segments;
                theta = fmod(theta, segmentAngle);
                theta = abs(theta - segmentAngle * 0.5);

                
                float2 kaleido = float2(cos(theta), sin(theta)) * r;

                
                float chaos = sin(kaleido.x * 8 + time * _ChaosSpeed) * cos(kaleido.y * 8 - time * _ChaosSpeed);
                kaleido += _DistortStrength * chaos;

                
                float calmPattern = smoothstep(0.2, 1.0, sin(r * 6 - time) * 0.5 + 0.5);
                float chaosPattern = smoothstep(0.2, 1.0, sin(r * 12 + chaos * 3.0) * 0.5 + 0.5);

                float blend = lerp(calmPattern, chaosPattern, _BlendChaos);
                float4 color = lerp(_MainColor, _ChaosColor, blend);

                return color * _Brightness;
            }
            ENDHLSL
        }
    }
}
