Shader "Unlit/K5"
{
  
    Properties
    {
        _Segments ("Segments", Range(2, 20)) = 8       
        _Rotation ("Rotation", Float) = 0              
        _Zoom ("Zoom", Float) = 1                      
        _Brightness ("Brightness", Float) = 1          
        _Glassiness ("Glassiness", Range(0, 5)) = 1    
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
            float _Pattern;

            // datos de entrada del mesh
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // lo que mandamos al fragment shader
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // vertex shader solo pasa los datos sin cambios
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // convierte a coords de pantalla
                o.uv = v.uv; // manda coords uv normales
                return o;
            }

            // convierte de hsv a rgb para hacer colores arcoiris
            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            // fragment shader aqui se dibuja el efecto visual
            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y; // tiempo para animar

                // centra la uv y aplica zoom
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;

                float r = length(uv); // distancia al centro
                float angle = atan2(uv.y, uv.x) + _Rotation; // angulo + rotacion

                // divide el circulo en segmentos simetricos
                float segmentAngle = 3.14159265 / _Segments;
                angle = fmod(angle, 2.0 * segmentAngle);
                angle = abs(angle - segmentAngle);

                // reconstruye coordenadas reflejadas para el patron
                float2 mirroredUV = float2(cos(angle), sin(angle)) * r;

                float val;

                // segun el tipo de patron cambia el efecto
                if (_Pattern < 0.5) {
                    // cuadricula ondulante
                    float2 grid = sin(mirroredUV * 12 + t);
                    val = (grid.x * grid.y) * 0.5 + 0.5;
                }
                else if (_Pattern < 1.5) {
                    // anillos que se mueven
                    val = sin(r * 20 - t * 4);
                    val = saturate(val * 0.5 + 0.5);
                }
                else {
                    // anillos con picos
                    float theta = atan2(mirroredUV.y, mirroredUV.x);
                    float rings = sin(r * 15 - t * 2);
                    float spikes = cos(theta * _Segments * 2);
                    val = rings * spikes;
                    val = saturate(val * 0.5 + 0.5);
                }

                // brillo suave desde el centro
                float glow = exp(-r * 2.5);
                val = saturate(val + glow * 0.8);

                // color arcoiris animado segun angulo y tiempo
                float hue = frac(angle / (2.0 * segmentAngle) + t * 0.1);
                float3 color = hsv2rgb(float3(hue, 1.0, 1.0));

                // controla que tan brillante se ve como vidrio
                float gloss = pow(val, _Glassiness * 2.5 + 0.5);

                // resultado final con color brillo y luz
                float3 finalColor = color * gloss * _Brightness;

                return float4(finalColor, 1);
            }
            ENDCG
        }
    }
}
