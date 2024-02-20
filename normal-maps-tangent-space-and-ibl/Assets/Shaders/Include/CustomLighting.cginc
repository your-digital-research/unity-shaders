#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING

#pragma multi_compile _SPECULARTYPE_PHONG _SPECULARTYPE_BLINN

sampler2D _MainTex;
float _Gloss;
float4 _Color;

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

    // Unity macro (to use TEXCOORD3 and TEXCOORD4)
    LIGHTING_COORDS(3, 4)
};

Interpolators vert(MeshData v)
{
    Interpolators o;

    o.vertex = UnityObjectToClipPos(v.vertex);

    // o.normal = v.normal;
    o.normal = UnityObjectToWorldNormal(v.normal);

    o.uv = v.uv;

    o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

    // Unity macro for lighting
    TRANSFER_VERTEX_TO_FRAGMENT(o);

    return o;
}

float4 frag(Interpolators i) : SV_Target
{
    float3 mainTex = tex2D(_MainTex, i.uv).rgb;
    float3 surface = mainTex * _Color.rgb;

    #ifdef USE_LIGHTING
        // BRDF - Bidirectional Reflectance Distribution Function
        // PBR - Physically Based Rendering

        // Remap glossiness variable
        float specularExponent = exp2(_Gloss * 7) + 2;

        float3 lightColor = _LightColor0.xyz;
        float attenuation = LIGHT_ATTENUATION(i);

        // Diffuse Lighting //

        float3 N = normalize(i.normal); // Normalize normals for smoothness for some cases
        // return float4(N, 1);

        float3 L = normalize(UnityWorldSpaceLightDir(i.worldPosition));
        //return float4(L, 1);

        // Lambertian reflectance
        // Use max or saturate function
        // float3 lambertian = max(0, dot(N, L));
        float3 lambertian = saturate(dot(N, L));

        // Diffuse Light
        // float3 diffuseLight = lambertian * lightColor;
        float3 diffuseLight = lambertian * attenuation * lightColor;

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
        specularLight *= attenuation;

        // return float4(specularLight, 1);

        // Final Color
        float4 finalColor = float4((diffuseLight * surface) + specularLight, 1);

        return finalColor;
    #else
        #ifdef BASE_PASS
            return surface;
        #else
            return 0;
        #endif
    #endif
}