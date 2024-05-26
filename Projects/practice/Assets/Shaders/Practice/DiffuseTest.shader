Shader "Practice/DiffuseTest"
{
    Properties
    {
        [Header(Surface)] [Space]
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTexture ("Main Texture", 2D) = "white" {}

        [Header(Settings)] [Space]
        _LightIntensity ("Light Intensity", Range(0, 1)) = 1
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
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

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
                float3 normalWorld: TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
            };

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            uniform float _LightIntensity;
            uniform float4 _Color;

            float3 LambertShading(float3 reflectionColor, float lightIntensity, float3 normal, float3 lightDirection)
            {
                // return reflectionColor * lightIntensity * max(0, dot(normal, lightDirection));
                return reflectionColor * lightIntensity * saturate(dot(normal, lightDirection));
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                // o.normalWorld = UnityObjectToWorldNormal(v.normal);
                o.normalWorld = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float4 mainTexture = tex2D(_MainTexture, i.uv);

                const float3 normal = i.normalWorld;
                const float3 reflectionColor = _LightColor0.xyz;
                const float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                // float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.worldPosition));

                const float3 diffuse = LambertShading(reflectionColor, _LightIntensity, normal, lightDirection);

                float3 surface = mainTexture * diffuse * _Color;

                return float4(surface, 1);
            }
            ENDCG
        }
    }
}