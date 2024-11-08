Shader "Personal/CustomLighting"
{
    Properties
    {
        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
        [NoScaleOffset] _NormalTex ("Normal Texture", 2D) = "bump" {}
        [NoScaleOffset] _HeightTex ("Height Texture", 2D) = "gray" {}
        [NoScaleOffset] _DiffuseIBL ("Diffuse Image Based Lighting", 2D) = "black" {}
        [NoScaleOffset] _SpecularIBL ("Specular Image Based Lighting", 2D) = "black" {}

        [Header(Settings)] [Space]
        _Gloss ("Gloss", Range(0, 1)) = 1
        _Fresnel ("Fresnel", Range(1, 10)) = 5
        _Color ("Color", Color) = (1, 1, 1, 1)
        _AmbientLight ("Ambient Light", Color) = (0, 0, 0, 0)
        _NormalIntensity ("Normal Intensity", Range(0, 1)) = 0
        _HeightIntensity ("Height Intensity", Range(0, 1)) = 0
        _DiffuseIBLIntensity ("Diffuse Image Based Lighting Intensity", Range(0, 1)) = 0.5
        _SpecularIBLIntensity ("Specular Image Based Lighting Intensity", Range(0, 1)) = 0.1

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