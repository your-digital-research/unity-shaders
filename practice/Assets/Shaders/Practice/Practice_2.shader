Shader "Practice/Practice_2"
{
    Properties
    {
        [Header(Textures)] [Space]
        [Toggle] _UseTexture ("Use Texture", Float) = 0
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}

        [Header(Progress)] [Space]
        _Health ("Health", Range(0, 1)) = 1

        [Header(Properties)] [Space]
        [Toggle] _RoundedCorners ("Rounded Corners", Float) = 0
        [Toggle] _BordersWithRoundedCorners ("Borders With Rounded Corners", Float) = 0
        _BorderSize ("Border Size", Range(0, 0.5)) = 0.25
        _YScale ("Y Scale", Float) = 0.2
        _Transparency ("Transparency", Range(0, 1)) = 1

        [Header(Ranges)] [Space]
        _Start ("Start", Range(0, 1)) = 0.25
        _End ("End", Range(0, 1)) = 0.75

        [Header(Colors)] [Space]
        _FromColor ("From Color", Color) = (1, 0, 0, 1)
        _ToColor ("To Color", Color) = (0, 1, 0, 1)

        [Header(Background)] [Space]
        [Toggle] _ClipBackground ("Clip Background", Float) = 0
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)

        [Header(Pulse)] [Space]
        _Threshold ("Threshold", Range(0, 1)) = 0.25
        _Magnitude ("Magnitude", Range(0, 1)) = 0.15
        _Frequency ("Frequency", Range(1, 5)) = 5
    }
    SubShader
    {
        Tags
        {
            // For non transparent background
            "RenderType"="Opaque"
            "Queue"="Geometry"

            // For transparent background
            // "RenderType"="Transparent"
            // "Queue"="Transparent"
        }

        Pass
        {
            // Disable ZWrite and use Alpha blending for transparency
            // ZWrite Off
            // Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _CLIPBACKGROUND_ON
            #pragma shader_feature _USETEXTURE_ON
            #pragma shader_feature _ROUNDEDCORNERS_ON
            #pragma shader_feature _BORDERSWITHROUNDEDCORNERS_ON

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

            sampler2D _MainTex;

            float _Health;

            float _BorderSize;
            float _YScale;
            float _Transparency;

            float _Start;
            float _End;

            float3 _FromColor;
            float3 _ToColor;
            float3 _BackgroundColor;

            float _Threshold;
            float _Magnitude;
            float _Frequency;

            float InverseLerp(float from, float to, float input)
            {
                return (input - from) / (to - from);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // Gradient with uv coordinates
                // float4 col = float4(i.uv, 0, 1);
                // return col;

                // Alpha gradient red color
                // return float4(1, 0, 0, i.uv.x);

                float sdf;
                float borderMask = 1;

                #if _ROUNDEDCORNERS_ON
                    float2 coordinates = i.uv;
                    float repeat = 1 / _YScale;
                    coordinates.x *= repeat;
                    // coordinates = frac(coordinates);

                    float2 pointOnLineSegment = float2(clamp(coordinates.x, 0.5, repeat - 0.5), 0.5);
                    sdf = distance(coordinates, pointOnLineSegment) * 2 - 1;

                    clip(-sdf);

                    // Show SDF
                    // return float4(coordinates, 0, 1);
                    // return float4(sdf.xxx, 1);

                    #if _BORDERSWITHROUNDEDCORNERS_ON
                        float borderSdf = sdf + _BorderSize;

                        // PD for - Partial Derivative
                        float pd = fwidth(borderSdf);
                        // Another way to calculate Partial Derivative
                        // length(float2(ddx(borderSdf), ddy(borderSdf)));

                        // Without antialiasing
                        // borderMask = step(0, -borderSdf);

                        // With antialiasing by Screen Space Partial Derivative
                        borderMask = 1 - saturate(borderSdf / pd);

                        // Show Border SDF
                        // return float4(borderMask.xxx, 1);
                    #endif
                #endif

                // + 1 at the end if we use * in the final calculation
                float pulse = cos(_Time.y * _Frequency) * _Magnitude + 1;

                // Just pulse effect
                // return float4(pulse.xxx, 1);

                // Check for mask
                float healthBarMask = _Health > i.uv.x;

                // Clip function (to discard background color)
                #if _CLIPBACKGROUND_ON
                    clip(healthBarMask - 0.5);
                #endif

                #if _USETEXTURE_ON
                    // Sample the texture
                    // float4 tex = tex2D(_MainTex, i.uv);
                    float4 tex = tex2D(_MainTex, float2(_Health, i.uv.y));

                    // Output either background color or texture color
                    float3 color = lerp(_BackgroundColor, tex, healthBarMask);

                    // Add pulsing to the final color based on threshold
                    if (_Health <= _Threshold)
                    {
                        color *= pulse;
                    }

                    // With background color (use clip function and without transparent tags)
                    return float4(color * borderMask, 0);

                    // Without background color (don't use clip function and with transparent tags)
                    // return  float4(color, healthBarMask * _Transparency);

                    // Return texture and black out background
                    // return float4(tex.rgb * healthBarMask, 1);

                    // Return one color texture ( + or * for different effect, hue/saturation, etc...)
                    // Note for * we add 1 at the pulse calculation at the end
                    // return float4(tex.rgb + pulse, 1);
                    // return float4(tex.rgb * pulse, 1);
                #else
                    // Remap
                    float t = saturate(InverseLerp(_Start, _End, _Health));

                    // Lerp color
                    float3 healthBarColor = lerp(_FromColor, _ToColor, t);

                    // Output either background color or health color
                    float3 color = lerp(_BackgroundColor, healthBarColor, healthBarMask);

                    // Add pulsing to the final color based on threshold
                    if (_Health <= _Threshold)
                    {
                        color *= pulse;
                    }

                    // With background color (use clip function and without transparent tags)
                    return float4(color * borderMask, 0);

                    // Another way to black out the background
                    // return float4(healthBarColor * healthBarMask, 1);

                    // Without background color (don't use clip function and with transparent tags)
                    // return  float4(healthBarColor, healthBarMask * _Transparency);
                #endif
            }
            ENDCG
        }
    }
}