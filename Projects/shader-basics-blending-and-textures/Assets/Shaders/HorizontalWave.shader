Shader "Personal/HorizontalWave"
{
    Properties
    {
        //
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

            Interpolators vert (MeshData v)
            {
                Interpolators i;

                i.vertex = UnityObjectToClipPos(v.vertex);
                i.normal = v.normal;
                i.uv = v.uv0;

                return i;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float xOffset = cos(i.uv.y * TAU * 2) * 0.01;
                float t = cos((i.uv.x + xOffset + _Time.y * 0.1) * TAU * 2) * 0.5 + 0.5;

                return t;
            }
            ENDCG
        }
    }
}