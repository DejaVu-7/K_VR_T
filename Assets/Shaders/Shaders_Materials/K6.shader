Shader "Unlit/K6"
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

            // info que recibe cada vertice
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

            // vertex shader es solo pasa los datos tal cual
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // pasa la posicion a la pantalla
                o.uv = v.uv; // manda las coordenadas UV
                return o;
            }

            // funcion para convertir de HSV a RGB
            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            // funcion que espejea los valores
            float mirror(float v) {
                return abs(frac(v * 0.5) * 2.0 - 1.0);
            }

            // fragment shader aquí se genera todo el patron visual
            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y; // tiempo para animar el shader

                // mueve el centro al medio y aplica zoom
                float2 uv = (i.uv - 0.5) * 2.0 * _Zoom;

                // espejea las coordenadas para simetria
                uv = float2(mirror(uv.x), mirror(uv.y));

                float r = length(uv); // distancia desde el centro
                float angle = atan2(uv.y, uv.x) + _Rotation; // angulo con rotacion

                // ajusta el angulo para que se repita por segmentos 
                float segmentAngle = 3.14159265 / _Segments;
                angle = fmod(angle, 2.0 * segmentAngle);
                angle = abs(angle - segmentAngle);

                // reconstruye coordenadas con el angulo modificado
                float2 mirroredUV = float2(cos(angle), sin(angle)) * r;

                float val;

                // elige el patron según el valor de _Pattern
                if (_Pattern < 0.5) {
                    // patron tipo cuadricula animada
                    float2 grid = sin(mirroredUV * 10 + t);
                    val = (grid.x * grid.y) * 0.5 + 0.5;
                }
                else if (_Pattern < 1.5) {
                    // patron de anillos que se mueven
                    val = sin(r * 20 - t * 4);
                    val = saturate(val * 0.5 + 0.5); 
                }
                else {
                    // patron de anillos con picos
                    float theta = atan2(mirroredUV.y, mirroredUV.x);
                    float rings = sin(r * 15 - t * 2);
                    float spikes = cos(theta * _Segments * 2);
                    val = rings * spikes;
                    val = saturate(val * 0.5 + 0.5);
                }

                // agrega brillo desde el centro
                float glow = exp(-r * _GlowStrength * 2.0);
                val = saturate(val + glow * 0.8); 

                // cambia el color dinamicamente con el tiempo y el angulo
                float hue = frac(angle / (2.0 * segmentAngle) + t * 0.1);
                float3 color = hsv2rgb(float3(hue, 1.0, 1.0)); 

                // ajusta el brillo con glassiness y brightness
                float gloss = pow(val, _Glassiness * 2.5 + 0.5);
                float3 finalColor = color * gloss * _Brightness;

                return float4(finalColor, 1); // color final del pixel 
            }
            ENDCG
        }
    }
}
