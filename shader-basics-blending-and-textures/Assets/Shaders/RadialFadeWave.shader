Shader "Personal/RadialFadeWave"
{
    Properties
    {
        _FromColor ("From Color", Color) = (1, 1, 1, 1)
        _ToColor ("To Color", Color) = (1, 1, 1, 1)
        _WaveAmplitude("Wave Amplitude", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.2831855

            float4 _FromColor;
            float4 _ToColor;
            float _WaveAmplitude;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            float GetWave(float2 uv)
            {
                float2 uvsCentered = uv * 2 - 1;

                float radialDistance = length(uvsCentered);
                float wave = cos((radialDistance - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;

                wave *= 1 - radialDistance;

                return wave;
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                v.vertex.y = GetWave(v.uv0) * _WaveAmplitude;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = v.uv0;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float wave = GetWave(i.uv);
                float4 gradient = lerp(_FromColor, _ToColor, i.uv.y);

                return wave * gradient;
            }
            ENDCG
        }
    }
}