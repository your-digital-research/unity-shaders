Shader "Personal/ExampleShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _UVScale ("UV Scale", Range (0, 2)) = 1
        _UVOffset ("UV Offset", Range (0, 1)) = 0
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

            float4 _Color;
            float _UVScale;
            float _UVOffset;

            struct MeshData
            {
                float4 vertex : POSITION; // vertex position
                float3 normal : NORMAL; // normal
                // float4 color : COLOR; // color
                // float4 tangent : TANGENT; // tangent
                float2 uv0 : TEXCOORD0; // uv0 diffuse/normal map textures
                // float2 uv1 : TEXCOORD1; // uv1 lightmap coordinates
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION; // clip space position
                float3 normal: TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators i;

                i.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                i.normal = v.normal;
                i.uv = v.uv0;

                // Transform normals from local to world space in different ways
                // i.normal = UnityObjectToWorldNormal(v.normal);
                // i.normal = mul(v.normal, (float3x3)unity_WorldToObject);
                // i.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
                // i.normal = mul((float3x3)UNITY_MATRIX_M, v.normal);

                // Offsetting and Scaling uv
                i.uv = (v.uv0 + _UVOffset) * _UVScale;

                return i;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // Swizzling and returning value
                // float2 value = float2(1, 1);
                // float4 color = value.xxxx;
                // return color;

                // Returning hard coded value
                // return float4(1, 1, 1, 1);

                // Returning _Color property
                // return _Color;

                // Returning normal
                // return float4(i.normal, 1);

                // Returning uv coordinates
                return float4(i.uv, 0, 1);
                // return float4(i.uv.xxx, 1);
                // return float4(i.uv.yyy, 1);
            }
            ENDCG
        }
    }
}