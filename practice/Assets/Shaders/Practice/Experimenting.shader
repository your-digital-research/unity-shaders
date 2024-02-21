Shader "Practice/Experimenting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlendTexture ("Blend Texture", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}

        _Speed ("Speed", Range(0, 5)) = 1
        _Amplitude ("Amplitude", Range(0, 1)) = 0.5

        _ColorStart ("Color Start", Range(0, 1)) = 0
        _ColorEnd ("Color End", Range(0, 1)) = 1

        _ColorFrom ("Color From", Color) = (0, 0, 0, 0)
        _ColorTo ("Color To", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderType"="Opaque"

            // "Queue" = "Transparent"
            // "RenderType"="Transparent"
        }

        // Cull Off
        // ZTest Off
        // ZWrite Off
        // Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define PI 3.1415926
            #define TAU 6.2831855

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldPosition: TEXCOORD2;
            };

            // Texture2D _MainTex;
            // SamplerState sampler_mainTex;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BlendTexture;
            float4 _BlendTexture_ST;

            sampler2D _Pattern;
            float4 _Pattern_ST;

            sampler2D _Noise;
            float4 _Noise_ST;

            float _Speed;
            float _Amplitude;

            float _ColorStart;
            float _ColorEnd;

            float4 _ColorFrom;
            float4 _ColorTo;

            float InverseLerp(float from, float to, float input)
            {
                return (input - from) / (to - from);
            }

            float GetWave(float2 uv)
            {
                // float2 uvsCentered = uv * 2 - 1;

                // float radialDistance = length(uvsCentered);
                float waveX = cos((uv.x - _Time.y * _Speed) * TAU) * 0.5 + 0.5;
                float waveY = sin((uv.y - _Time.y * _Speed) * TAU) * 0.5 + 0.5;

                // wave = 1 - radialDistance;
                float wave = waveX;

                return wave * 0.5 + 0.5;
            }

            float GetPattern(float coordinates)
            {
                float wave = cos((coordinates - _Time.y * _Speed) * TAU * 5) * 0.5 + 0.5;

                wave *= 1 - coordinates;

                return wave;
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                // v.vertex.y = GetWave(v.uv0) * _Amplitude;

                o.vertex = UnityObjectToClipPos(v.vertex);

                // o.normal = UnityObjectToWorldNormal(v.normal);
                o.normal = v.normal;

                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                // o.uv = v.uv0;

                o.uv.x += _Time.y * _Speed;

                o.worldPosition = mul(UNITY_MATRIX_M, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // float t1 = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                // float t2 = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.y));

                // float4 colorA = lerp(_ColorFrom, _ColorTo, t1);
                // float4 colorB = lerp(_ColorFrom, _ColorTo, t2);

                // float xWave = cos((i.uv.x + _Time.y * _Speed) * TAU) * 0.5 + 0.5;
                // float yWave = cos((i.uv.y + _Time.y * _Speed) * TAU) * 0.5 + 0.5;

                // float wave = GetWave(i.uv);
                // float4 gradient = lerp(_ColorFrom, _ColorTo, i.uv.y);

                // float xOffset = cos(i.uv.y * TAU);
                // float t = cos((i.uv.x + xOffset - _Time.y * _Speed) * TAU * 2) * 0.5 + 0.5;

                // t *= 1 - i.uv.y;
                // t *= abs(i.normal.y) < 1;

                // float4 gradient = lerp(_ColorFrom, _ColorTo, i.uv.y);

                // float yOffset = i.uv.x;
                // float t = sin((i.uv.y - yOffset + _Time.y * _Speed) * TAU * 5) * 0.5 + 0.5;

                // t *= 1 - i.uv.y;
                // t *= abs(i.normal.y) < 0.5;

                // float2 topDownProjection = i.worldPosition.xz;

                float4 mainTexture = tex2D(_MainTex, i.uv);
                float4 blendTexture = tex2D(_BlendTexture, i.uv);
                float4 pattern = tex2D(_Pattern, i.uv);
                float4 noise = tex2D(_Noise, i.uv);

                float4 finalColor = lerp(mainTexture, blendTexture, noise);
                // float4 finalColor = lerp(float4(1, 1, 1, 1), mainTexture, pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}