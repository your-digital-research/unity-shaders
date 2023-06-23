Shader "Personal/VerticalFadeWave"
{
    Properties
    {
        _FromColor ("From Color", Color) = (1, 1, 1, 1)
        _ToColor ("To Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" // Tag to inform the render pipeline of what type this is
            "Queue"="Transparent" // Changes render queue
        }

        Pass
        {
            // Cull Off // Culling disabled
            Cull Back // Default Culling, hides back face
            // Cull Front // Hides front face

            ZWrite Off // Depth buffer write
            ZTest LEqual // Depth buffer read (default LEqual, GEqual, Always)

            Blend One One // Additive blending
            // Blend DstColor Zero // Multiply blending

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.2831855

            float4 _FromColor;
            float4 _ToColor;

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
                float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 2) * 0.5 + 0.5;

                t *= 1 - i.uv.y; // Fade
                t *= abs(i.normal.y) < 1; // Hide top and bottom faces

                float4 gradient = lerp(_FromColor, _ToColor, i.uv.y);

                return t * gradient;
            }
            ENDCG
        }
    }
}