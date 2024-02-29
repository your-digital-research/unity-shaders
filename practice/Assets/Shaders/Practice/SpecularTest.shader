Shader "Practice/SpecularTest"
{
    Properties
    {
        [Header(Surface)] [Space]
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTexture ("Main Texture", 2D) = "white" {}

        [Header(Specular)] [Space]
        [Toggle] _UseSpecularTexture ("Use Specular Texture", Float) = 0
        [NoScaleOffset] _SpecularTexture ("Specular Texture", 2D) = "black" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 1
        _SpecularPower ("Specular Power", Range(1, 128)) = 64
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

            #pragma shader_feature _USESPECULARTEXTURE_ON

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
                float3 normalWorld : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
            };

            uniform float4 _Color;

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            uniform sampler2D _SpecularTexture;
            uniform float4 _SpecularTexture_ST;

            uniform float _SpecularIntensity;
            uniform float _SpecularPower;

            float3 SpecularShading(float3 reflectionColor, float specularIntensity, float3 normal, float3 lightDirection, float3 viewDirection, float specularPower)
            {
                const float3 halfVector = normalize(lightDirection + viewDirection); // Halfway

                // return reflectionColor * specularIntensity * pow(max(0, dot(normal, halfVector)), specularPower);
                return reflectionColor * specularIntensity * pow(saturate(dot(normal, halfVector)), specularPower);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                // o.normalWorld = normalize(mul(unity_ObjectToWorld, v.normal));
                o.normalWorld = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                const float4 mainTexture = tex2D(_MainTexture, i.uv);
                const float4 specularTexture = tex2D(_SpecularTexture, i.uv);

                const float3 normal = i.normalWorld;

                #ifdef _USESPECULARTEXTURE_ON
                    const float3 reflectionColor = specularTexture * _LightColor0;
                #else
                    const float3 reflectionColor = _LightColor0;
                #endif

                const float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                const float3 viewDirection = normalize(_WorldSpaceCameraPos - i.worldPosition);

                const float3 specular = SpecularShading(reflectionColor, _SpecularIntensity, normal, lightDirection, viewDirection, _SpecularPower);

                float3 surface = mainTexture * _Color;
                surface.rgb += specular;

                return float4(surface, 1);
            }
            ENDCG
        }
    }
}