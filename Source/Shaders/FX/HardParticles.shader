﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Particles/Hard Particles" {
	Properties {
		_TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 1)
		_MainTex ("Muzzle Texture", 2D) = "white" {}
		_GlowBoost ("Glow Boost", Range(0, 1)) = 0
	}
	
	Category {
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		Blend SrcAlpha One
		Cull Off
		Lighting Off
		ZWrite Off
		
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		//Fragment program cards
		SubShader {
			Pass {
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				
				#include "UnityCG.cginc"
				
				sampler2D _MainTex;
				fixed4 _TintColor;
				half _GlowBoost;
				
				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};
				
				struct v2f {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
				};
				
				float4 _MainTex_ST;
				
				v2f vert(appdata_t v) {
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}
								
				fixed4 frag(v2f i) : COLOR {
					fixed4 col = 2.0f * (1 + _GlowBoost) * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG
			}
		}
		
		//Dual texture cards
		SubShader {
			Pass {
				SetTexture[_MainTex] {
					constantColor [_TintColor]
					combine texture * primary
				}
				SetTexture[_MainTex] {
					combine texture * previous DOUBLE
				}
			}
		}
		
		//Single texture cards
		SubShader {
			Pass {
				SetTexture[_MainTex] {
					combine texture * primary
				}
			}
		}
	}
}