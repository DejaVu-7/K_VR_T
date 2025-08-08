Shader "Unlit/KaleidoscopeTunnel"
{
    Properties
    {
        _Segments ("Symmetry Segments", Range(2, 20)) = 6
        _Rotation ("Rotation", Float) = 0
        _Zoom ("Zoom", Float) = 1
        _Brightness ("Brightness", Float) = 1
        _GlowStrength ("Glow Strength", Range(0, 5)) = 1
        _Speed ("Tunnel Speed", Float) = 0.5
        _Distort ("Depth Distortion", Float) = 0.5
        _Color1 ("Primary Color", Color) = (1, 0, 0, 1)
        _Color2 ("Secondary Color", Color) = (0, 0, 1, 1)
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

            sampler2D _MainTex;
            float _Segments;
            float _Rotation;
            float _Zoom;
            float _Brightness;
            float _GlowStrength;
            float _Speed;
            float _Distort;
            fixed4 _Color1;
            fixed4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2.0 - 1.0; // centrar
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // Convertir a coordenadas polares
                float r = length(uv);
                float a = atan2(uv.y, uv.x);

                // Crear simetría tipo caleidoscopio
                a = fmod(a, 2.0 * UNITY_PI / _Segments);
                a = abs(a - (UNITY_PI / _Segments));

                // Movimiento del túnel
                r = r * _Zoom + _Time.y * _Speed;
                
                // Distorsión para dar profundidad
                r += sin(r * 3.0 + _Time.y) * _Distort * 0.1;

                // Patrón de colores
                float pattern = sin(r * 10.0) * 0.5 + 0.5;
                fixed4 col = lerp(_Color1, _Color2, pattern);

                // Brillo y resplandor
                float glow = pow(1.0 - abs(sin(r * 2.0)), _GlowStrength);
                col.rgb *= _Brightness + glow;

                return col;
            }
            ENDCG
        }
    }
}
