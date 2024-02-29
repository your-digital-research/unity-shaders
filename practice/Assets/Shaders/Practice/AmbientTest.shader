Shader "Practice/AmbientTest"
{
    Properties
    {
        [Header(Textures)] [Space]
        [NoScaleOffset] _MainTexture ("Texture", 2D) = "white" {}

        [Header(Settings)] [Space]
        [Toggle] _UseUnityAmbientColor ("Use Unity Ambient Color", Float) = 0
        _AmbientColor ("Ambient Color", Color) = (0, 0, 0, 0)
        _AmbientIntensity ("Ambient Intensity", Range(0, 1)) = 0.5
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

            #pragma shader_feature _USEUNITYAMBIENTCOLOR_ON

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST;

            uniform float4 _AmbientColor;
            uniform float _AmbientIntensity;

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float4 mainTexture = tex2D(_MainTexture, i.uv);

                const float3 unityAmbientColor = UNITY_LIGHTMODEL_AMBIENT * _AmbientIntensity;
                const float3 manualAmbientColor = _AmbientColor * _AmbientIntensity;

                float3 surface = mainTexture;

                #ifdef _USEUNITYAMBIENTCOLOR_ON
                    surface += unityAmbientColor;
                #endif

                surface += manualAmbientColor;

                return float4(surface, 1);
            }
            ENDCG
        }
    }
}