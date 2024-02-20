#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING
#define TAU 6.2831855

#pragma multi_compile _SPECULARTYPE_PHONG _SPECULARTYPE_BLINN

sampler2D _MainTex;
sampler2D _NormalTex;
sampler2D _HeightTex;
sampler2D _DiffuseIBL;
sampler2D _SpecularIBL;

float _Gloss;
float _Fresnel;

float4 _Color;
float4 _AmbientLight;

float _NormalIntensity;
float _HeightIntensity;
float _DiffuseIBLIntensity;
float _SpecularIBLIntensity;

float2 DirectionToRectilinear(float3 direction)
{
    float x = atan2(direction.z, direction.x) / TAU + 0.5; // Range from 0 to 1
    float y = direction.y * 0.5 + 0.5; // Range from 0 to 1

    return float2(x, y);
}

struct MeshData
{
    float4 vertex : POSITION;
    float3 normal: NORMAL;
    float4 tangent: TANGENT; // xyz -> Tangent Direction, w -> Tangent Sign
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 vertex : SV_POSITION;
    float3 normal: TEXCOORD0;
    float3 tangent: TEXCOORD1;
    float3 biTangent: TEXCOORD2;
    float2 uv : TEXCOORD3;
    float3 worldPosition: TEXCOORD4;

    // Unity macro (to use TEXCOORD5 and TEXCOORD6)
    LIGHTING_COORDS(5, 6)
};

Interpolators vert(MeshData v)
{
    Interpolators o;

    // Simple wave using normals
    // v.vertex.xyz += v.normal * cos(v.uv.x * 8 + _Time.y) * 0.05;

    // Getting height and mapping it to range from -1 to 1
    float height = tex2Dlod(_HeightTex, float4(v.uv, 0, 0)).x * 2 - 1;

    // Offsetting based on a Height Map
    v.vertex.xyz += v.normal * height * _HeightIntensity;

    o.vertex = UnityObjectToClipPos(v.vertex);

    // o.normal = v.normal;
    o.normal = UnityObjectToWorldNormal(v.normal);

    // o.tangent = v.tangent.xyz;
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);

    o.biTangent = cross(o.normal, o.tangent);

    // v.tangent.w - is -1 or 1 for shifted UV
    // unity_WorldTransformParams.w -> Handle flipping/scaling/mirroring of object in Unity
    o.biTangent *= v.tangent.w * unity_WorldTransformParams.w;

    o.uv = v.uv;

    o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

    // Unity macro for lighting
    TRANSFER_VERTEX_TO_FRAGMENT(o);

    return o;
}

float4 frag(Interpolators i) : SV_Target
{
    // Debug for Image Based Lighting
    // #ifdef BASE_PASS
    //     // float3 diffuseIBL = tex2Dlod(_DiffuseIBL, float4(DirectionToRectilinear(i.normal), 0, 0)).xyz;
    //     // return float4(diffuseIBL, 0);
    //
    //     float mipLevel = 5;
    //     float mip = (1 - _Gloss) * mipLevel;
    //     float3 view = normalize(_WorldSpaceCameraPos - i.worldPosition);
    //     float3 reflection = reflect(-view, i.normal);
    //     float3 specularIBL = tex2Dlod(_SpecularIBL, float4(DirectionToRectilinear(reflection), mip, mip)).xyz;
    //
    //     return float4(specularIBL, 0);
    // #else
    //     return float4(0, 0, 0, 0);
    // #endif

    float3 mainTex = tex2D(_MainTex, i.uv).rgb;
    float3 surface = mainTex * _Color.rgb;

    float4 unpackedNormals = tex2D(_NormalTex, i.uv);

    // Tangent space normals (packedNormals)
    float3 tangentSpaceNormals = float4(UnpackNormal(unpackedNormals), 0);

    tangentSpaceNormals = normalize(lerp(float3(0, 0, 1), tangentSpaceNormals, _NormalIntensity));

    // Debug for tangents
    // #ifdef BASE_PASS
    //     return float4(tangentSpaceNormals, 0);
    // #else
    //     return 0;
    // #endif

    float3x3 TangentToWorldMatrix =
    {
        i.tangent.x, i.biTangent.x, i.normal.x,
        i.tangent.y, i.biTangent.y, i.normal.y,
        i.tangent.z, i.biTangent.z, i.normal.z,
    };

    float3 N = mul(TangentToWorldMatrix, tangentSpaceNormals);

    #ifdef USE_LIGHTING
        // BRDF - Bidirectional Reflectance Distribution Function
        // PBR - Physically Based Rendering

        // Remap glossiness variable
        float specularExponent = exp2(_Gloss * 7) + 2;

        float3 lightColor = _LightColor0.xyz;
        float attenuation = LIGHT_ATTENUATION(i);

        // Diffuse Lighting //

        // Commented to calculate normals above
        // float3 N = normalize(i.normal); // Normalize normals for smoothness for some cases
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

        // Calculate diffuse lighting from image
        float3 diffuseIBL = tex2Dlod(_DiffuseIBL, float4(DirectionToRectilinear(N), 0, 0)).xyz;

        #ifdef BASE_PASS
            // Adds the indirect diffuse lighting
            diffuseLight += _AmbientLight;

            // Add diffuse lighting calculated from image
            diffuseLight += diffuseIBL * _DiffuseIBLIntensity;
        #endif

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

        #ifdef BASE_PASS
            // Use fresnel to reduce the reflection at the center
            float fresnel = pow(1 - saturate(dot(V, N)), _Fresnel);

            float mipLevel = 5;
            float mip = (1 - _Gloss) * mipLevel;

            float3 reflection = reflect(-V, N);

            float3 specularIBL = tex2Dlod(_SpecularIBL, float4(DirectionToRectilinear(reflection), mip, mip)).xyz;

            specularLight += specularIBL * _SpecularIBLIntensity * fresnel;
        #endif

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