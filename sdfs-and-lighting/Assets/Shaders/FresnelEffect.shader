Shader "Personal/FresnelEffect"
{
    Properties
    {
        //
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldPosition: TEXCOORD2;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                // o.normal = v.normal;
                o.normal = UnityObjectToWorldNormal(v.normal);

                o.uv = v.uv;

                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 N = normalize(i.normal);

                float3 V = normalize(_WorldSpaceCameraPos - i.worldPosition);

                float fresnel = 1 - dot(V, N);

                return fresnel;
            }
            ENDCG
        }
    }
}