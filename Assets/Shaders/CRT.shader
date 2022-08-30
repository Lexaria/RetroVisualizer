Shader "Custom/CRT"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		
		[Header(Noise)]
		[Space(5)]
		_NoiseTex ("Noise Texture", 2D) = "white" {}
		_NoiseAmount ("Noise Amount", Range(0, 1)) = 0.5
		_NoiseSpeed ("Noise Speed", Range(-10, 10)) = 1

		[Space(30)]
		
		[Header(ScanningLine)]
		[Space(5)]
		_ScanningLineSpeed ("Scanning Line Speed", Range(-10, 10)) = 1
		_ScanningLineWidth ("Scanning Line Width", Range(0, 1)) = 0.25
		_ScanningLineAmount ("Scanning Line Amount", Range(0, 1)) = 0.25

		_ScanningLineMin ("Scanning Line Min", Range(0, 1)) = 0.6
		_ScanningLineMax ("Scanning Line Max", Range(0, 1)) = 1.0
		
		_ScanningLineBlinkSpeed ("Scanning Line Blink Speed", Range(0, 30)) = 15
		

	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"
		}

		Pass
		{
			HLSLPROGRAM
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

			#pragma vertex vert
			#pragma fragment frag
			
			TEXTURE2D(_MainTex); Texture2D _NoiseTex;
			SAMPLER(sampler_MainTex); SamplerState sampler_NoiseTex;
			float4 _NoiseTex_ST;
			
			float _NumOfBands;
			float _ScanningLineWidth;
			float _ScanningLineAmount;
			float _ScanningLineSpeed;
			float _ScanningLineBlinkSpeed;
			float _ScanningLineMin, _ScanningLineMax;
			float _NoiseAmount;
			float _NoiseSpeed;

			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float2 uv : TEXCOORD0;
				float2 uv_noise : TEXCOORD1;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				output.vertex = vertexInput.positionCS;
				output.uv = input.uv;
				output.uv_noise = TRANSFORM_TEX(input.uv, _NoiseTex);

				return output;
			}

			half remap(half x, half t1, half t2, half s1, half s2)
			{
				return (x - t1) / (t2 - t1) * (s2 - s1) + s1;
			}

			float4 frag(Varyings input) : SV_Target
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
				float scanningLineMask = input.uv.y * _NumOfBands;
				scanningLineMask += frac(_Time.x * _ScanningLineSpeed);
				scanningLineMask = step(frac(scanningLineMask), _ScanningLineWidth);
				float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
				float scanningLineBlink = saturate(sin(_Time.x * _ScanningLineBlinkSpeed));
				scanningLineBlink = remap(scanningLineBlink, 0.0, 1.0, _ScanningLineMin, _ScanningLineMax);
				input.uv_noise.y += frac(_Time.x * _NoiseSpeed);
				float var_noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, input.uv_noise).r;
				float3 finalRGB = lerp(color, scanningLineMask * scanningLineBlink, _ScanningLineAmount);
				finalRGB = lerp(finalRGB, _NoiseAmount, var_noise);
				return float4(finalRGB, 1);
			}
			ENDHLSL
		}
	}
	FallBack "Diffuse"
}