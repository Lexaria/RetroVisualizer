Shader "Custom/SpectrumCube"
{

	Properties
	{
		[Header(Texture)]
		[Space(5)]
		[MainTexture] _BaseMap("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" {}
		[HDR] _EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity ("Emission Intensity", Range(0, 30)) = 2
		[Header(UV)]
		[Space(5)]
		_InitialOffset ("Initial UV Offset", float) = 0
		_UVSpeed ("UV Move Speed", Range(-10, 10)) = 1
		[Space(30)]
		
		[Header(Object Move)]
		[Space(3)]
		_MoveSpeed ("Object Move Speed", Range(-10, 10)) = 1
		_MoveRange ("Object Move Range", Range(0, 5)) = 1
		[Space(30)]


		[Toggle(_ALPHATEST_ON)] _AlphaTestToggle ("Alpha Clipping", Float) = 0
		_Cutoff ("Alpha Cutoff", Float) = 0.5
	}

	// The SubShader block containing the Shader code. 
	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags
		{
			"RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline"
		}

		Pass
		{
			Name "SpectrumCubeForward"
			Tags
			{
				"LightMode" = "UniversalForward"
			}

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
			// receive shadow
			// #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			// #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

			// V11
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

			// Baked Lightmap
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK

			// GPU Instancing
			#pragma multi_compile_instancing

			// Fog
			#pragma multi_compile_fog


			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMap_ST;
			float4 _EmissionColor;
			float _InitialOffset;
			float _EmissionIntensity;
			float _UVSpeed;
			float _MoveSpeed, _MoveRange;
			CBUFFER_END

			
			Texture2D _BaseMap;
			SamplerState sampler_BaseMap;
			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv: TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 uv: TEXCOORD1;
			};


			Varyings vert(Attributes IN)
			{
				Varyings OUT = (Varyings)0;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				IN.positionOS.y += sin(frac(_Time.z * _MoveSpeed) * TWO_PI) * _MoveRange;
				const VertexPositionInputs vertex_position_inputs = GetVertexPositionInputs(IN.positionOS);
				OUT.positionCS = vertex_position_inputs.positionCS;
				OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);

				return OUT;
			}


			half4 frag(Varyings IN) : SV_Target
			{

				float2 sampleUV = IN.uv / 8 + float2(_InitialOffset, 0);
				sampleUV.x += frac(-_Time.x * _UVSpeed);
				float4 var_BaseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, sampleUV);
				// float3 finalRGB = var_BaseMap.rgb + _EmissionColor.rgb;
				float4 var_EmissionColor = _EmissionColor * _EmissionIntensity;
				float3 finalRGB = var_BaseMap.rgb * var_EmissionColor;
				return half4(finalRGB, 1);
			}
			ENDHLSL
		}
		UsePass "Universal Render Pipeline/Lit/ShadowCaster"
		UsePass "Universal Render Pipeline/Lit/DepthOnly"
		UsePass "Universal Render Pipeline/Lit/DepthNormals"
		UsePass "Universal Render Pipeline/Lit/Meta"
		UsePass "Universal Render Pipeline/Lit/Universal2D"
	}
}