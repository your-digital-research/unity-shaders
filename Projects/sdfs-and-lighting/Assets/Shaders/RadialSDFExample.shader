Shader "Personal/RadialSDFExample"
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

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2 - 1;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // Display centered UV coordinates
                // return float4(i.uv, 0, 1);

                float color;
                float shift = 0.5;

                // Display radial distance to the center (SDF)
                // float distance = distance(float2(0, 0), i.uv);
                float distance = length(i.uv) - shift;

                color = float4(distance.xxx, 1);

                // return color;

                // Show black where distance is negative and show white where distance is positive
                // step function fot threshold
                color = step(0, distance);

                return color;
            }
            ENDCG
        }
    }
}