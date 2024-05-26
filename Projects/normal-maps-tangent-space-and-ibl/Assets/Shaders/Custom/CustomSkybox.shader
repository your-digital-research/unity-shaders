Shader "Personal/CustomSkybox"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

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
                float3 viewDirection : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 viewDirection : TEXCOORD0;
            };

            sampler2D _MainTex;

            float2 DirectionToRectilinear(float3 direction)
            {
                float x = atan2(direction.z, direction.x) / TAU + 0.5; // Range from 0 to 1
                float y = direction.y * 0.5 + 0.5; // Range from 0 to 1

                return float2(x, y);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDirection = v.viewDirection;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float4 col = tex2Dlod(_MainTex, float4(DirectionToRectilinear(i.viewDirection), 0, 0));

                // Return View Direction
                // return float4(i.viewDirection, 1);

                return col;
            }
            ENDCG
        }
    }
}