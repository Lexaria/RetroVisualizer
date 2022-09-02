Shader "Custom/Rainbow"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_Distance ("Distance", Range(0, 10000)) = 1600 //nm
		
		[Header(Normal)]
		[Space(5)]
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Range(0, 1)) = 0.5
		[Space(30)]
		
		[Header(Noise)]
		[Space(5)]
		_NoiseTex ("Noise Texture", 2D) = "white" {}
		_NoiseAmount ("Noise Amount", Range(0, 1)) = 0.5
		_NoiseSpeed ("Noise Speed", Range(-10, 10)) = 1



	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"RenderPipeline" = "UniversalPipeline"
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha


			HLSLPROGRAM
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"

			#pragma vertex vert
			#pragma fragment frag
			// V11
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

			TEXTURE2D(_MainTex);
			Texture2D _NoiseTex, _NormalMap;
			SAMPLER(sampler_MainTex);
			SamplerState sampler_NoiseTex, sampler_NormalMap;
			float4 _NoiseTex_ST;

			float _NoiseAmount;
			float _NoiseSpeed;
			float _Distance;
			float _BumpScale;

			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
				float3 normalOS: NORMAL;
				float4 tangentOS: TANGENT;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_noise : TEXCOORD1;
				float3 positionWS : TEXCOORD02;
				float3 normalWS: TEXCOORD3;
				float3 tangentWS : TEXCOORD4;
				float3 bitangentWS: TEXCOORD5;
				UNITY_VERTEX_OUTPUT_STEREO
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				const VertexPositionInputs vertex_position_inputs = GetVertexPositionInputs(input.positionOS.xyz);
				const VertexNormalInputs vertex_normal_inputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

				output.positionCS = vertex_position_inputs.positionCS;
				output.positionWS = vertex_position_inputs.positionWS;
				output.normalWS = vertex_normal_inputs.normalWS;
				output.tangentWS = vertex_normal_inputs.tangentWS;
				output.bitangentWS = vertex_normal_inputs.bitangentWS;

				output.uv = input.uv;
				output.uv_noise = TRANSFORM_TEX(input.uv, _NoiseTex);
				return output;
			}

			// Spektre
			half3 spectral_spektre(float l)
			{
				float r = 0.0, g = 0.0, b = 0.0;
				if ((l >= 400.0) && (l < 410.0))
				{
					float t = (l - 400.0) / (410.0 - 400.0);
					r = +(0.33 * t) - (0.20 * t * t);
				}
				else if ((l >= 410.0) && (l < 475.0))
				{
					float t = (l - 410.0) / (475.0 - 410.0);
					r = 0.14 - (0.13 * t * t);
				}
				else if ((l >= 545.0) && (l < 595.0))
				{
					float t = (l - 545.0) / (595.0 - 545.0);
					r = +(1.98 * t) - (t * t);
				}
				else if ((l >= 595.0) && (l < 650.0))
				{
					float t = (l - 595.0) / (650.0 - 595.0);
					r = 0.98 + (0.06 * t) - (0.40 * t * t);
				}
				else if ((l >= 650.0) && (l < 700.0))
				{
					float t = (l - 650.0) / (700.0 - 650.0);
					r = 0.65 - (0.84 * t) + (0.20 * t * t);
				}
				if ((l >= 415.0) && (l < 475.0))
				{
					float t = (l - 415.0) / (475.0 - 415.0);
					g = +(0.80 * t * t);
				}
				else if ((l >= 475.0) && (l < 590.0))
				{
					float t = (l - 475.0) / (590.0 - 475.0);
					g = 0.8 + (0.76 * t) - (0.80 * t * t);
				}
				else if ((l >= 585.0) && (l < 639.0))
				{
					float t = (l - 585.0) / (639.0 - 585.0);
					g = 0.82 - (0.80 * t);
				}
				if ((l >= 400.0) && (l < 475.0))
				{
					float t = (l - 400.0) / (475.0 - 400.0);
					b = +(2.20 * t) - (1.50 * t * t);
				}
				else if ((l >= 475.0) && (l < 560.0))
				{
					float t = (l - 475.0) / (560.0 - 475.0);
					b = 0.7 - (t) + (0.30 * t * t);
				}

				return half3(r, g, b);
			}

			float RGBtoLum(float3 color)
			{
				return (0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b);
			}

			float4 frag(Varyings input) : SV_Target
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				// Light
				Light mainLight = GetMainLight();
				float3 lightDir = normalize(mainLight.direction);
				float3 viewWS = GetWorldSpaceViewDir(input.positionWS);
				viewWS = normalize(viewWS);
				// Normal & Tangent
				float2 var_NoiseMap = _NoiseAmount * SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, input.uv_noise + frac(_Time.x * _NoiseSpeed)).rr;
				float3 var_noiseVector = UnpackNormalScale(
					SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv + var_NoiseMap), _BumpScale);
				float3 noiseVecWS = TransformTangentToWorld(var_noiseVector,
														float3x3(input.tangentWS, input.bitangentWS, input.normalWS));
				noiseVecWS = NormalizeNormalPerPixel(noiseVecWS);
				float3 tangentWS = normalize(input.tangentWS + noiseVecWS);


				float cos_L = dot(lightDir, tangentWS);
				float cos_V = dot(viewWS, tangentWS);
				float u = abs(cos_L - cos_V);
				float d = _Distance;

				half3 color = 0;
				for (int n = 1; n <= 8; n++)
				{
					float wavelength = u * d / n;
					color += spectral_spektre(wavelength);
				}
				color = saturate(color);
				return float4(color, 1);
			}
			ENDHLSL
		}
	}
	FallBack "Diffuse"
}