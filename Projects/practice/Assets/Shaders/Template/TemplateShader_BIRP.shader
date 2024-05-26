Shader "Template/TemplateShader_BIRP"
{
    Properties
    {
        [Header(Surface)] [Space]
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTexture ("Main Texture", 2D) = "white" {}
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

            uniform float4 _Color;

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                const float4 mainTexture = tex2D(_MainTexture, i.uv);

                float3 surface = mainTexture;

                surface.rgb *= _Color;

                return float4(surface, 1);
            }
            ENDCG
        }
    }
}