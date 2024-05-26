Shader "Practice/ShadowTest_URP"
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
            "RenderPipeline"="UniversalRenderPipeline"
        }

        // Default Color Pass
        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            // Causes redefinition errors and warning
            // #include "HLSLSupport.cginc"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 shadowCoordinate : TEXCOORD1;
            };

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);

                // Find VertexPositionInputs at Core.hlsl
                // Find GetVertexPositionInputs at ShaderVariablesFunctions.hlsl
                const VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);

                // Find GetShadowCoord at Shadows.hlsl
                o.shadowCoordinate = GetShadowCoord(vertexInput);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // Find GetMainLight function at Lighting.hlsl
                const Light light = GetMainLight(i.shadowCoordinate);
                const float3 shadow = light.shadowAttenuation;

                const float4 mainTexture = tex2D(_MainTexture, i.uv);

                float3 surface = mainTexture;

                surface *= shadow;

                return float4(surface, 1);
            }
            ENDHLSL
        }

        // Shadow Caster Pass
        UsePass "Universal Render Pipeline/Lit/SHADOWCASTER"
    }
}