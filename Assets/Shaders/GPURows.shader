// Shader "leesue/GPURows"
// {
// 	Properties{
// 		_MainTex("Albedo (RGB)", 2D) = "white" {}
// 		_Glossiness("Smoothness", Range(0,1)) = 0.5
// 		_Metallic("Metallic", Range(0,1)) = 0.0
// 	}
// 		SubShader{
// 		Tags{ "RenderType" = "Opaque" }
// 		LOD 200

// 		CGPROGRAM
// 		// Physically based Standard lighting model
// 		#pragma surface surf Standard addshadow
// 		#pragma multi_compile_instancing
// 		#pragma instancing_options procedural:setup

// 		sampler2D _MainTex;

// 		struct Input {
// 			float2 uv_MainTex;
// 		};

// 		#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// 			StructuredBuffer<float4> shderBuffer;
// 		#endif
// 		float _Dim;
// 		// float _PosX;
// 		// float _PosY;
// 		// float _PosZ;

// 		float rand(in float2 uv)
// 		{
// 			float2 noise = (frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453));
// 			return abs(noise.x + noise.y) * 0.5;
// 		}

// 		void rotate2D(inout float2 v, float r)
// 		{
// 			float s, c;
// 			sincos(r, s, c);
// 			v = float2(v.x * c - v.y * s, v.x * s + v.y * c);
// 		}

// 	void setup()
// 	{
// 		// this uv assumes the # of instances is _Dim * _Dim. 
// 		// so we calculate the uv inside a grid of _Dim x _Dim elements.
// 		// float2 uv = float2( floor(unity_InstanceID / _Dim) / _Dim, (unity_InstanceID % (int)_Dim) / _Dim);
// 		// in this case, _Dim can be replaced by the size in the world
// 		float4 position = float4(0, 0, 1, 1);
// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// 		position = shderBuffer[unity_InstanceID][1];
// #endif
// 		// float4 position = float4(_PosX,_PosY,_PosZ,1); 
// 		// float4 position = float4(10,10,10,1); 

// 		float4 rotation = (0,0,0,0);
// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// 		rotation = shderBuffer[unity_InstanceID][2];
// #endif

// 		// rotate2D(position.yz, rotation.x);
// 		// rotate2D(position.xz, rotation.y);
// 		// rotate2D(position.xy, rotation.z);

// 		float scale = position.w;
// 		// float scale = 100;

// 		unity_ObjectToWorld._11_21_31_41 = float4(scale, 0, 0, 0);
// 		unity_ObjectToWorld._12_22_32_42 = float4(0, scale, 0, 0);
// 		unity_ObjectToWorld._13_23_33_43 = float4(0, 0, scale, 0);
// 		unity_ObjectToWorld._14_24_34_44 = float4(position.xyz, 1);

// 		unity_WorldToObject = unity_ObjectToWorld;
// 		unity_WorldToObject._14_24_34 *= -1;
// 		unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
// 	}

// 	half _Glossiness;
// 	half _Metallic;

// 	void surf(Input IN, inout SurfaceOutputStandard o) 
// 	{
// 		float4 col = 1.0f;

// #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
// 		col = shderBuffer[unity_InstanceID][0];
// #else
// 		col = float4(0, 0, 1, 1);
// #endif
// 		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * col;
// 		o.Albedo = c.rgb;
// 		o.Metallic = _Metallic;
// 		o.Smoothness = _Glossiness;
// 		o.Alpha = c.a;
// 	}
// 	ENDCG
// 	}
// 	FallBack "Diffuse"
// }
Shader "leesue/GPURows"
{
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model
		#pragma surface surf Standard addshadow vertex:vert
		#pragma multi_compile_instancing
		#pragma instancing_options procedural:setup

		sampler2D _MainTex;

		struct Input {
			float4 position;
			float2 uv_MainTex;
		};

		#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
			StructuredBuffer<float4> colorBuffer;
			StructuredBuffer<float4> positionBuffer;
			StructuredBuffer<float4> rotationBuffer;
		#endif
		float _Dim;

		float rand(in float2 uv)
		{
			float2 noise = (frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453));
			return abs(noise.x + noise.y) * 0.5;
		}

	void setup()
	{
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		// this uv assumes the # of instances is _Dim * _Dim. 
		// so we calculate the uv inside a grid of _Dim x _Dim elements.
		float2 uv = float2( floor(unity_InstanceID / _Dim) / _Dim, (unity_InstanceID % (int)_Dim) / _Dim);
		// in this case, _Dim can be replaced by the size in the world
		// float4 position = float4((uv.x - 0.5) * _Dim, 0, (uv.y - 0.5) * _Dim, rand(uv)); 
		float4 position = positionBuffer[unity_InstanceID];
		float scale = position.w;

		// float rotation = scale * scale * _Time.y * 0.5f;

		unity_ObjectToWorld._11_21_31_41 = float4(scale, 0, 0, 0);
		unity_ObjectToWorld._12_22_32_42 = float4(0, scale, 0, 0);
		unity_ObjectToWorld._13_23_33_43 = float4(0, 0, scale, 0);
		unity_ObjectToWorld._14_24_34_44 = float4(position.xyz, 1);
		unity_WorldToObject = unity_ObjectToWorld;
		unity_WorldToObject._14_24_34 *= -1;
		unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
#endif
	}

	half _Glossiness;
	half _Metallic;

	void vert(inout appdata_full v)
	{
		float4 rot = float4(0,0,0,0);
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		rot = rotationBuffer[unity_InstanceID];
#endif
		//x,y,z 为随时间变化的量，数值可以自己随意设置
		// float x =  rot.x;
		// float y =  rot.y;
		// float z =  rot.z;
		float x =  rot.x;
		float y =  rot.y;
		float z =  90;
		//定义一个 4*4 的矩阵类型，将旋转和平移包含进去
		float4x4 mx = {1,0,0,0,
			0,cos(x),-sin(x),0,
			0,sin(x),cos(x),0,
			0,0,0,1};
		float4x4 my = {cos(y),0,sin(-y),0,
			0,1,0,0,
			-sin(-y),0,cos(y),0,
			0,0,0,1};
		float4x4 mz = {cos(z),sin(z),0,0,
			-sin(z),cos(z),0,0,
			0,0,1,0,
			0,0,0,1};
		//对顶点进行变换
		v.vertex = mul(mx,v.vertex);
		v.vertex = mul(my,v.vertex);
		v.vertex = mul(mz,v.vertex);
	}

	void surf(Input IN, inout SurfaceOutputStandard o) 
	{
		float4 col = 1.0f;

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		col = colorBuffer[unity_InstanceID * 2 + 1];
#endif
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * col;
		o.Albedo = c.rgb;
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
		o.Alpha = c.a;
	}
	ENDCG
	}
	FallBack "Diffuse"
}
