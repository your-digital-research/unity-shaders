Shader "Practice/ShadowTest"
{
    Properties
    {
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
            Name "Shadow Caster"

            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ShadowCaster"
            }

            ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            // struct MeshData
            // {
            //     // We need only the position of vertices as input
            //     // float4 vertex : POSITION;
            // };

            struct Interpolators
            {
                // We need only the position of vertices as output
                // float4 vertex : SV_POSITION;

                V2F_SHADOW_CASTER;
            };

            Interpolators vert(appdata_full v)
            {
                Interpolators o;

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        Pass
        {
            Name "Shadow Map Texture"

            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase"
            }

            // Default Color Pass
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // WITH MACROS
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "AutoLight.cginc" // WITH MACROS

            struct MeshData
            {
                float4 vertex : POSITION;

                // float2 uv : TEXCOORD0; // WITHOUT MACROS
                float2 texcoord : TEXCOORD0; // WITH MACROS
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;

                // Store shadow data int TEXCOORD1
                SHADOW_COORDS(1) // WITH MACROS

                // float4 vertex : SV_POSITION; // WITHOUT MACROS
                float4 pos: SV_POSITION; // WITH MACROS

                // float4 shadowCoordinate : TEXCOORD1; // WITHOUT MACROS
            };

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            // Declare a sampler for the Shadow Map
            // uniform sampler2D _ShadowMapTexture; // WITHOUT MACROS

            float4 NDCToUV(float4 clipPos)
            {
                float4 o = clipPos * 0.5;

                #if defined(UNITY_HALF_TEXEL_OFFSET)
                    o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w * _ScreenParams.zw;
                #else
                    o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                #endif

                o.zw = clipPos.zw;

                return o;
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                UNITY_INITIALIZE_OUTPUT(Interpolators, o)

                // o.vertex = UnityObjectToClipPos(v.vertex); // WITHOUT MACROS
                o.pos = UnityObjectToClipPos(v.vertex); // WITH MACROS

                // o.uv = TRANSFORM_TEX(v.uv, _MainTexture); // WITHOUT MACROS
                o.uv = v.texcoord; // WITH MACROS

                // o.shadowCoordinate = NDCToUV(o.vertex); // WITHOUT MACROS
                TRANSFER_SHADOW(o) // WITH MACROS

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                const float4 mainTexture = tex2D(_MainTexture, i.uv);

                // WITHOUT MACROS
                // Create the UV coordinate for the shadow
                // const float2 shadowUV = i.shadowCoordinate.xy / i.shadowCoordinate.w;
                // Save the shadow texture in the shadow variable
                // const float shadow = tex2D(_ShadowMapTexture, shadowUV).a;

                // WITH MACROS
                const float shadow = SHADOW_ATTENUATION(i);

                float4 surface = mainTexture;
                surface.rgb *= shadow;

                return surface;
            }
            ENDCG
        }
    }
}