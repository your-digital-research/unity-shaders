Shader "Personal/TextureMasking"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pattern ("Texture", 2D) = "white" {}
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
            sampler2D _Pattern;

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

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float4 mainTexture = tex2D(_MainTex, i.uv);
                float4 pattern = tex2D(_Pattern, i.uv);

                float4 finalColor = lerp(float4(1, 1, 1, 1), mainTexture, pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}