Shader "Practice/TestShader"
{
    Properties
    {
        [Header(Textures)]
        [NoScaleOffset] _MainTexture ("Texture", 2D) = "white" {}
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

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);

                // o.uv = v.uv * 2 - 1; // Center UV

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // float4 col = tex2D(_MainTexture, i.uv);
                // return col;

                float u = i.uv.x;
                float v = i.uv.y;

                return float4(u, v, 0, 0);
            }
            ENDCG
        }
    }
}