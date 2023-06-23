Shader "Personal/TextureWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pattern ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
            sampler2D _Pattern;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float GetWave(float coordinates)
            {
                float wave = cos((coordinates - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                wave *= 1 - coordinates;

                return wave;
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float4 mainTexture = tex2D(_MainTex, i.uv);
                float4 pattern = tex2D(_Pattern, i.uv);

                return GetWave(pattern);
            }
            ENDCG
        }
    }
}