Shader "Practice/AmbientReflectionTest"
{
    Properties
    {
        [Header(Surface)] [Space]
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTexture ("Main Texture", 2D) = "white" {}

        [Header(Ambient Reflection)] [Space]
        [Toggle] _UseUnitySkyboxReflection ("Use Unity Skybox Reflection", Float) = 0
        [NoScaleOffset] _ReflectionTexture ("Reflection Texture", Cube) = "white" {}
        _ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 1
        _ReflectionMetallic ("Reflection Metallic", Range(0, 1)) = 1
        _ReflectionDetail ("Reflection Detail", Range(1, 9)) = 1
        _ReflectionExposure ("Reflection Exposure", Range(1, 3)) = 1
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

            #pragma shader_feature _USEUNITYSKYBOXREFLECTION_ON

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
                float3 worldNormal : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
            };

            uniform float4 _Color;

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            uniform samplerCUBE _ReflectionTexture;
            uniform float _ReflectionIntensity;
            uniform float _ReflectionMetallic;
            uniform float _ReflectionDetail;
            uniform float _ReflectionExposure;

            float3 AmbientReflection(samplerCUBE reflectionColor, float reflectionIntensity, float reflectionDetail, float3 normal, float3 viewDirection, float reflectionExposure)
            {
                float3 worldReflection = reflect(-viewDirection, normal); // Negative view direction for this case
                float4 cubemap = texCUBElod(reflectionColor, float4(worldReflection, reflectionDetail));

                // float4 texCUBElod(samplerCUBE samp, float4 s)
                // s.xyz = reflection coordinates
                // s.w = texel density

                return reflectionIntensity * cubemap.rgb * (cubemap.a * reflectionExposure);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                const float4 mainTexture = tex2D(_MainTexture, i.uv);

                const float3 normal = i.worldNormal;
                const float3 viewDirection = normalize(UnityObjectToWorldDir(i.worldPosition));

                float3 surface = mainTexture;

                surface.rgb *= _Color;

                #ifdef _USEUNITYSKYBOXREFLECTION_ON
                    const float3 worldReflection = reflect(-viewDirection, normal);
                    const float4 reflectionData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldReflection);

                    float3 reflectionColor = DecodeHDR(reflectionData, unity_SpecCube0_HDR);

                    reflectionColor *= _ReflectionIntensity;

                    surface.rgb += reflectionColor;
                #else
                    const samplerCUBE reflectionColor = _ReflectionTexture;

                    const float3 ambientReflection = AmbientReflection(reflectionColor, _ReflectionIntensity, _ReflectionDetail, normal, viewDirection, _ReflectionExposure);

                    surface.rgb *= ambientReflection + _ReflectionMetallic;
                #endif

                return float4(surface, 1);
            }
            ENDCG
        }
    }
}