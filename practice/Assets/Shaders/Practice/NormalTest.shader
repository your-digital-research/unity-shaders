Shader "Practice/NormalTest"
{
    Properties
    {
        [Header(Surface)] [Space]
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTexture ("Main Texture", 2D) = "white" {}

        [Header(Normal)] [Space]
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalIntensity ("Normal Intensity", Range(0, 1)) = 1
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
                float4 tangent : TANGENT;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvNormal: TEXCOORD1;
                float3 normalWorld : TEXCOORD2;
                float4 tangentWorld : TEXCOORD3;
                float3 biNormalWorld : TEXCOORD4;
            };

            uniform float4 _Color;

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;
            uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST;

            uniform float _NormalIntensity;

            float3 DXTCompression(float4 normalMap)
            {
                #if defined (UNITY_NO_DXT5nm)
                    return normalMap.rgb * 2 - 1;
                #else
                    float3 normalColor;

                    normalColor = float3(normalMap.a * 2 - 1, normalMap.g * 2 - 1, 0 );
                    normalColor.b = sqrt(1 - (pow(normalColor.r, 2) + pow(normalColor.g, 2)));

                    return normalColor;
                #endif
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                UNITY_INITIALIZE_OUTPUT(Interpolators, o);

                o.vertex = UnityObjectToClipPos(v.vertex);

                // Assigning UVs
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                o.uvNormal = TRANSFORM_TEX(v.uv, _NormalMap);

                // Normal to world space
                // o.normalWorld = UnityObjectToWorldNormal(v.normal);
                o.normalWorld = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));

                // Tangent to world space
                o.tangentWorld = normalize(mul(unity_ObjectToWorld, v.tangent));

                // Calculate the Cross Product between normals and tangents
                o.biNormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                const float4 mainTexture = tex2D(_MainTexture, i.uv);
                // return mainTexture;

                const float4 normalMap = tex2D(_NormalMap, i.uvNormal);
                float3 normalCompressed = DXTCompression(normalMap);
                // float3 normalCompressed = UnpackNormal(normalMap);
                // return float4(normalCompressed, 0);

                normalCompressed = normalize(lerp(float3(0, 0, 1), normalCompressed, _NormalIntensity));
                // return float4(normalCompressed, 0);

                // Tangent Binormal Normal matrix
                // float3x3 MatrixTBN = float3x3
                // (
                //     i.tangentWorld.xyz,
                //     i.biNormalWorld,
                //     i.normalWorld
                // );
                //
                // float3 normalColor = normalize(mul(normalCompressed, MatrixTBN));

                const float3x3 MatrixTBN =
                {
                    i.tangentWorld.x, i.biNormalWorld.x, i.normalWorld.x,
                    i.tangentWorld.y, i.biNormalWorld.y, i.normalWorld.y,
                    i.tangentWorld.z, i.biNormalWorld.z, i.normalWorld.z,
                };

                float3 normalColor = normalize(mul(MatrixTBN, normalCompressed));
                // return float4(normalColor, 0);

                float3 surface = mainTexture * _Color;
                return float4(surface, 1);
            }
            ENDCG
        }
    }
}