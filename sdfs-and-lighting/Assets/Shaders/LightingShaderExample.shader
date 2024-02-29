Shader "Personal/LightingShaderExample"
{
    Properties
    {
        [Header(Settings)] [Space]
        _Gloss ("Gloss", Range(0, 1)) = 1
        _Color ("Color", Color) = (1, 1, 1, 1)
        [Toggle] _Fresnel ("Fresnel", Float) = 0
        [Toggle] _PulseFresnel ("Pulse Fresnel", Float) = 0
        _FresnelPulseSpeed ("Fresnel Pulse Speed", Range(0, 5)) = 1

        [Header(Specular)] [Space]
        [KeywordEnum(Phong, Blinn)]
        _SpecularType ("Specular Type", Float) = 0
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile _SPECULARTYPE_PHONG _SPECULARTYPE_BLINN
            #pragma shader_feature _FRESNEL_ON
            #pragma shader_feature _PULSEFRESNEL_ON

            float _Gloss;
            float4 _Color;
            float _FresnelPulseSpeed;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldPosition: TEXCOORD2;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                // o.normal = v.normal;
                o.normal = UnityObjectToWorldNormal(v.normal);

                o.uv = v.uv;

                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // BRDF - Bidirectional Reflectance Distribution Function
                // PBR - Physically Based Rendering

                // Remap glossiness variable
                float specularExponent = exp2(_Gloss * 7) + 2;

                float3 lightColor = _LightColor0.xyz;

                // Diffuse Lighting //

                float3 N = normalize(i.normal); // Normalize normals for smoothness for some cases
                // return float4(N, 1);

                float3 L = _WorldSpaceLightPos0.xyz; // Direction, not a position
                // return float4(L, 1);

                // Lambertian reflectance
                // Use max or saturate function
                // float3 lambertian = max(0, dot(N, L));
                float3 lambertian = saturate(dot(N, L));

                // Diffuse Light
                // float3 diffuseLight = lambertian * lightColor;
                float3 diffuseLight =  lambertian * lightColor;

                // Specular Lighting //

                // View vector
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPosition);
                // return float4(V, 1);

                // Reflected vector
                float3 R = reflect(-L, N);
                // return float4(R, 1);

                // Half way vector
                float3 H = normalize(L + V);
                // return float4(H, 1);

                // Specular Light
                float3 specularLight;

                // Choose specular
                #if _SPECULARTYPE_PHONG
                    specularLight = saturate(dot(V, R));
                #elif _SPECULARTYPE_BLINN
                    specularLight = saturate(dot(H, N));
                #endif

                specularLight *= lightColor;
                specularLight *= lambertian > 0; // to remove spotlight at certain angle
                specularLight = pow(specularLight, specularExponent); // Specular exponent -> _GLoss

                // return float4(specularLight, 1);

                // Final Color
                float4 finalColor;

                #if _FRESNEL_ON
                    float fresnel = 1 - dot(V, N);

                    #if _PULSEFRESNEL_ON
                        fresnel *= cos(_Time.y * _FresnelPulseSpeed) * 0.5 + 0.5;
                    #endif

                    finalColor = float4((diffuseLight * _Color) + specularLight + fresnel, 1);
                #else
                    finalColor = float4((diffuseLight * _Color) + specularLight, 1);
                #endif

                return finalColor;
            }
            ENDCG
        }
    }
}