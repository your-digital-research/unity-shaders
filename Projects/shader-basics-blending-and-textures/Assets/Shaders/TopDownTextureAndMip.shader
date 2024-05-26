Shader "Personal/TopDownTextureAndMip"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MipSampleLevel ("Mip", Range(0, 10)) = 0
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MipSampleLevel;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex); // Object to world

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz;

                // float4 col = tex2D(_MainTex, topDownProjection); // Without Mip
                float4 col = tex2Dlod(_MainTex, float4(topDownProjection, _MipSampleLevel.xx)); // With Mip

                return col;
            }
            ENDCG
        }
    }
}