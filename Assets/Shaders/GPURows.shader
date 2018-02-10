Shader "leesue/GPURows" {
    Properties {}
    SubShader {
        Pass {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma target 4.5

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;

        #if SHADER_TARGET >= 45
            StructuredBuffer<float4> positionBuffer;
            StructuredBuffer<float4> rotationBuffer;
            StructuredBuffer<float4> colorBuffer;
        #endif

            struct v2f
            {
                float4 pos : SV_POSITION;
				float4 col : TEXCOORD0;
                // SHADOW_COORDS(4)
            };

            void rotate2D(inout float2 v, float r)
            {
                float s, c;
                sincos(r, s, c);
                v = float2(v.x * c - v.y * s, v.x * s + v.y * c);
            }

            v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
            {
                float PI = 3.141592653f;
            #if SHADER_TARGET >= 45
                float4 data = positionBuffer[instanceID];
            #else
                float4 data = 0;
            #endif

                // float rotation = data.w * data.w * _Time.x * 0.5f;
                // rotate2D(data.xz, rotation);

                float3 localPosition = v.vertex.xyz * data.w;

				float4 rot = float4(0, 0, 0, 0);
	// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            #if SHADER_TARGET >= 45
				rot = rotationBuffer[instanceID];
            #endif
				float x = -rot.x * PI / 180;
				float y = -rot.y * PI / 180;
				float z = -rot.z * PI / 180;
				//定义一个 4*4 的矩阵类型，将旋转和平移包含进去
				float4x4 mx = {1, 0, 0, 0,
							0, cos(x), sin(x), 0,
							0, -sin(x), cos(x), 0,
							0, 0, 0, 1};
				float4x4 my = {cos(y), 0, sin(-y), 0,
							0, 1, 0, 0,
							-sin(-y), 0, cos(y), 0,
							0, 0, 0, 1};
				float4x4 mz = {cos(z), sin(z), 0, 0,
							-sin(z), cos(z), 0, 0,
							0, 0, 1, 0,
							0, 0, 0, 1};
				//对顶点进行变换
				// localPosition = mul(mz, localPosition)+mul(mx, localPosition)+mul(my, localPosition);
				localPosition = mul(mz, localPosition);
				localPosition = mul(mx, localPosition);
				localPosition = mul(my, localPosition);

                float3 worldPosition = data.xyz + localPosition;

                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
#if SHADER_TARGET >= 45
				o.col = colorBuffer[instanceID];
#else
				o.col = 0.5f;
#endif
                // TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed shadow = SHADOW_ATTENUATION(i);
                // fixed4 albedo = tex2D(_MainTex, i.uv_MainTex);
                // float3 lighting = i.diffuse * shadow + i.ambient;
                // fixed4 output = fixed4(albedo.rgb * i.color * lighting, albedo.w);
                // UNITY_APPLY_FOG(i.fogCoord, output);
                // return output;
			return i.col;
            }
            ENDCG
        }
    }
}




// Shader "leesue/GPURows"{
// 	Properties{}
// 	SubShader{
// 		Tags{"RenderType" = "Opaque"}
// 		LOD 200
// 		Pass{
// 			CGPROGRAM
// // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members position,uv_MainTex)
// #pragma exclude_renderers d3d11
// // Physically based Standard lighting model
// // #pragma surface surf Standard addshadow vertex:vert
// #pragma vertex : vert
// #pragma fragment : frag
// // #pragma multi_compile_instancing
// // #pragma instancing_options procedural : setup

// 		struct v2f
// 		{
// 			float4 vertex : SV_POSITION;
// 		};

// 		struct a2v {
// 			float4 vertex : POSITION;
// 		};

// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// 		StructuredBuffer<float4> colorBuffer;
// 		StructuredBuffer<float4> positionBuffer;
// 		StructuredBuffer<float4> rotationBuffer;
// #endif

// // 		void setup(){
// // #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// // 			// this uv assumes the # of instances is _Dim * _Dim.
// // 			// so we calculate the uv inside a grid of _Dim x _Dim elements.
// // 			// in this case, _Dim can be replaced by the size in the world
// // 			// float4 position = float4((uv.x - 0.5) * _Dim, 0, (uv.y - 0.5) * _Dim, rand(uv));
// // 			float4 position = positionBuffer[unity_InstanceID];
// // 			float scale = position.w;

// // 			// float rotation = scale * scale * _Time.y * 0.5f;

// // 			unity_ObjectToWorld._11_21_31_41 = float4(scale, 0, 0, 0);
// // 			unity_ObjectToWorld._12_22_32_42 = float4(0, scale, 0, 0);
// // 			unity_ObjectToWorld._13_23_33_43 = float4(0, 0, scale, 0);
// // 			unity_ObjectToWorld._14_24_34_44 = float4(position.xyz, 1);
// // 			unity_WorldToObject = unity_ObjectToWorld;
// // 			unity_WorldToObject._14_24_34 *= -1;
// // 			unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
// // #endif
// // 		}

// 		v2f vert(a2v va){
// 			v2f v;
// 			v.vertex = va.vertex;
// 			float4 rot = float4(0, 0, 0, 0);
// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// 			rot = rotationBuffer[unity_InstanceID];
// #endif
// 			float x = rot.x;
// 			float y = rot.y;
// 			float z = rot.z;
// 			//定义一个 4*4 的矩阵类型，将旋转和平移包含进去
// 			float4x4 mx = {1, 0, 0, 0,
// 						   0, cos(x), -sin(x), 0,
// 						   0, sin(x), cos(x), 0,
// 						   0, 0, 0, 1};
// 			float4x4 my = {cos(y), 0, sin(-y), 0,
// 						   0, 1, 0, 0,
// 						   -sin(-y), 0, cos(y), 0,
// 						   0, 0, 0, 1};
// 			float4x4 mz = {cos(z), sin(z), 0, 0,
// 						   -sin(z), cos(z), 0, 0,
// 						   0, 0, 1, 0,
// 						   0, 0, 0, 1};
// 			//对顶点进行变换
// 			v.vertex = mul(mx, v.vertex);
// 			v.vertex = mul(my, v.vertex);
// 			v.vertex = mul(mz, v.vertex);

// 			// float4 pos = positionBuffer[unity_InstanceID];
// 			// v.vertex.xyz *= pos.w;
// 			// v.vertex.xyz += pos.xyz;
// 			return v;
// 		}

// 		fixed4 frag(v2f v){
// 			float4 col = 1.0f;
// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// 			col = colorBuffer[unity_InstanceID];
// #endif
// 			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * col;
// 			return col;
// 		}
// 		ENDCG
// 	}
// }
// 	FallBack "Diffuse"
	
// }
