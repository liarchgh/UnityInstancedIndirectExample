// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "leesue/row" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		// _MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1
		_HowMuchSpec("How much specular", float) = 1
	}
	SubShader {
		Tags{"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			ZWrite On
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha, One Zero
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			fixed4 _Color;
			// sampler2D _MainTex;
			// float4 _MainTex_ST;
			fixed _AlphaScale;
			float _HowMuchSpec;

			// struct a2v
			// {
			// 	float4 vertex : POSITION;
			// 	float3 normal : NORMAL;
			// 	float4 texcoord : TEXCOORD0;
			// };

			struct v2f
			{
				float4 pos : SV_POSITION;
				//float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
				//float3 lightDir : TEXCOORD1;
				//float3 viewDir : TEXCOORD2;
				float4 worldPos : TEXCOORD1;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				//o.pos = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				//o.pos = v.vertex;
				// o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal = mul(unity_ObjectToWorld, v.normal);
				// o.normal = UnityObjectToClipPos(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// fixed4 texColor = tex2D(_MainTex, i.uv);
				// fixed4 finCol = fixed4(texColor.rgb * _Color.rgb, texColor.a * _AlphaScale);
				fixed4 finCol = fixed4(_Color.rgb, _AlphaScale);
				// return finCol;
				//light
				fixed3 lightDir = normalize(WorldSpaceLightDir(i.pos));
				//fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				//viewDir
				//fixed3 viewDir = normalize(WorldSpaceViewDir(i.pos));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				//normal
				fixed3 normal = normalize(i.normal);
				// return fixed4(normal * 0.5 + 0.5, 1);

				//diffuse
				float lize = dot(normal, lightDir);
				//lize *= 10;
				lize = (lize + 1) / 2;
				//finCol = lize * finCol;
				//return finCol;


				//spec
				fixed4 _SpecColor = fixed4(1, 1, 1, 5);
				//float _HowMuchSpec = 6;
				fixed ndl = dot(normal, lightDir);

				fixed3 mostView = ndl * normal * 2 - lightDir;



				fixed vdmv = viewDir * mostView;

				if (vdmv < 0 || ndl < 0) {
					vdmv = 0;
				}
				vdmv = pow(vdmv, _HowMuchSpec);
				finCol += vdmv * _SpecColor;
				//finCol.a = 0.2;		
				//finCol = fixed4(vdmv, vdmv, vdmv, 1);
				//finCol = fixed4(lightDir,  1);
				//finCol = finCol * 0.5 + 0.5;
				return finCol;

				//  return float4(lightDir, 1);
				// return fixed4(texColor.rgb * _Color.rgb, texColor.a * _AlphaScale);
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
