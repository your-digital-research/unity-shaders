Shader "Personal/TwoColorHorizontalGradient"
{
    Properties
    {
        _FromColor ("From Color", Color) = (1, 1, 1, 1)
        _ToColor ("To Color", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0, 1)) = 0
        _ColorEnd ("Color End", Range(0, 1)) = 1
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

            float4 _FromColor;
            float4 _ToColor;
            float _ColorStart;
            float _ColorEnd;

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

            float InverseLerp(float from, float to, float input)
            {
                return (input - from) / (to - from);
            }

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
                // Blend two colors based on the X UV coordinate
                float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                float4 outputColor = lerp(_FromColor, _ToColor, t);

                return outputColor;
            }
            ENDCG
        }
    }
}