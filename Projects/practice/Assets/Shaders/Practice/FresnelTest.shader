Shader "Practice/FresnelTest"
{
    Properties
    {
        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTexture ("Main Texture", 2D) = "white" {}

        [Header(Fresnel)] [Space]
        _FresnelPower ("Fresnel Power", Range(1, 5)) = 1
        _FresnelIntensity ("Fresnel Intensity", Range(0, 1)) = 1
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
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWorld : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
            };

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            uniform float _FresnelPower;
            uniform float _FresnelIntensity;

            void FresnelEffect(in float3 normal, in float3 viewDirection, float power, out float Out)
            {
                Out = pow(1 - saturate(dot(normal, viewDirection)), power);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                o.normalWorld = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                const float4 mainTexture = tex2D(_MainTexture, i.uv);

                float fresnel = 0;
                const float3 normal = i.normalWorld;
                const float3 viewDirection = normalize(_WorldSpaceCameraPos - i.worldPosition);

                FresnelEffect(normal, viewDirection, _FresnelPower, fresnel);

                float3 surface = mainTexture;

                surface += fresnel * _FresnelIntensity;

                return float4(surface, 1);
            }
            ENDCG
        }
    }
}