Shader "Practice/CustomLighting"
{
    Properties
    {
        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}

        [Header(Settings)] [Space]
        _Gloss ("Gloss", Range(0, 1)) = 1
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Header(Specular)] [Space]
        [KeywordEnum(Phong, Blinn)]
        _SpecularType ("Specular Type", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        // Base Pass
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define BASE_PASS

            #include "Assets/Shaders/Include/CustomLighting.cginc"
            ENDCG
        }

        // Add Pass
        Pass
        {
            Tags
            {
                "LightMode"="ForwardAdd"
            }

            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #define ADD_PASS

            #include "Assets/Shaders/Include/CustomLighting.cginc"
            ENDCG
        }
    }
}