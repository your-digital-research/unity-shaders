Shader "Practice/TestShader"
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

            uniform sampler2D _MainTex;

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = v.uv * 2 - 1; // Center UV
                o.uv = v.uv;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // float4 col = tex2D(_MainTex, i.uv);
                // return col;

                float u = i.uv.x;
                float v = i.uv.y;

                return float4(u, v, 0, 0);
            }
            ENDCG
        }
    }
}