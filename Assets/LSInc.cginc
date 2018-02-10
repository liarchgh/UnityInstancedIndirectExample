// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

sampler2D _MainTex;
float4 _MainTex_ST;

#include "UnityCG.cginc"

struct v2f
{
	float2 uv : TEXCOORD0;
	UNITY_FOG_COORDS(1)
	float4 clipPos: SV_POSITION;
	float4 objPos: TEXCOORD1;
	float3 normal : NORMAL;
	fixed4 color : Color;
	float4 worldPos : TEXCOORD2;
};

v2f vert(appdata_full v)
{
	v2f o;
	o.clipPos = UnityObjectToClipPos(v.vertex);
	o.objPos = v.vertex;
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.uv = TRANSFORM_TEX(fixed2(0, 0), _MainTex);
	o.normal = normalize(mul(unity_ObjectToWorld, v.normal));
	UNITY_TRANSFER_FOG(o, o.vertex);
	return o;
}

fixed4 fragShowLightDir(v2f i) : SV_Target
{
	//light
	fixed3 lightDir = normalize(WorldSpaceLightDir(i.clipPos));
	fixed4 col = fixed4(lightDir * 0.5 + 0.5, 1.0f);
	return col;
}

fixed4 fragShowNormal(v2f i) : SV_Target
{
	fixed3 normal = i.normal;
	// fixed lize = mul(normal, lightDir);
	normal = normalize(normal);
	fixed4 col = fixed4(normal * 0.5 + 0.5, 1);
	return col;
}

fixed4 fragShowView(v2f i) : SV_Target
{
	fixed3 viewDir = normalize(WorldSpaceViewDir(i.objPos));
	fixed4 col = fixed4(viewDir * 0.5 + 0.5, 1);
	return col;
}

fixed4 fragMine(v2f i) : SV_Target
{
	// sample the texture
	fixed4 col = tex2D(_MainTex, i.uv);
	// apply fog
	// UNITY_APPLY_FOG(i.fogCoord, col);
	//normal
	fixed3 normal = i.normal;
	//light
	fixed3 lightDir = normalize(WorldSpaceLightDir(i.clipPos));
	//viewDir
	fixed3 viewDir = normalize(WorldSpaceViewDir(i.objPos));
	//viewDir multiply lightDir

	//diffuse
	fixed lize = mul(normal, lightDir);
	col = ((lize * 0.5) + 0.5) * col;

	//spec
	fixed4 _SpecColor = fixed4(1,1,1,1);
	float _HowMuchSpec = 5;
	fixed ndl = normal * lightDir;
	fixed3 mostView = ndl * normal * 2 - lightDir;
	col += pow(viewDir * lightDir, 2) * _SpecColor;
	fixed vdmv = viewDir * mostView;
	if(vdmv < 0 || ndl < 0) vdmv = 0;
	vdmv = pow(vdmv, _HowMuchSpec);
	col += vdmv * _SpecColor * ndl;
	
	return col;
}

fixed4 fragShowMostView(v2f i) : SV_Target
{
	// if(i.worldPos.x != i.clipPos.x && i.worldPos.y != i.clipPos.y && i.worldPos.z != i.clipPos.z){
	// 	return fixed4(0,0,0,1);
	// }
	fixed4 col = 0;
	//normal
	fixed3 normal = i.normal;
	//light
	fixed3 lightDir = normalize(WorldSpaceLightDir(i.worldPos));
	//spec
	fixed ndl = normal * lightDir;
	fixed3 mostView = ndl * normal * 2 - lightDir;

	// col = fixed4((fixed3)(ndl * 0.5 + 0.5), 1);
	col = fixed4(mostView * 0.5 + 0.5, 1);
	return col;
}