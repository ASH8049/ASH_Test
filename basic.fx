//------------------------------------------------
// グローバル変数
//------------------------------------------------

float4x4	g_world;					// ワールド変換行列
float4x4 	g_view;						// カメラ変換行列
float4x4 	g_projection;				// プロジェクション変換行列

texture		g_toon;
texture		g_texture;					// テクスチャ
bool		g_tex;						// テクスチャのありなし　false:なし　true:あり

// 光
float4		g_diffuse;					// ディフューズ
float4		g_emmisive;					// エミッシブ
float4		g_ambient;					// 環境光
float4		g_specular;					// スペキュラー光

float3		g_light_dir;				// 平行光源の方向

// マテリアル
float4		g_diffuse_mat;				// ディフューズ光
float4		g_emmisive_mat;				// エミッシブ光
float4		g_ambient_mat;				// 環境光
float4		g_specular_mat;				// スペキュラー
float		g_power;					// スペキュラー光のパワー値
float4		g_camerapos;				// カメラ位置


//------------------------------------------------
// サンプラー1
//------------------------------------------------
sampler TextureSampler1 =
sampler_state{
	Texture = <g_texture>;
	MinFilter= LINEAR;		// リニアフィルタ（縮小時）
	MagFilter= LINEAR;		// リニアフィルタ（拡大時）
//	MinFilter= POINT;		// フィルタをかけない
//	MagFilter= POINT;		// フィルタをかけない
//	MinFilter= ANISOTROPIC;		// 異方性フィルタ（縮小時）
//	MagFilter= ANISOTROPIC;		// 異方性フィルタ（拡大時）
};

sampler ToonSampler1 =
sampler_state{
	Texture = <g_toon>;
	MinFilter = LINEAR;		// リニアフィルタ（縮小時）
	MagFilter = LINEAR;		// リニアフィルタ（拡大時）
	//	MinFilter= POINT;		// フィルタをかけない
	//	MagFilter= POINT;		// フィルタをかけない
	//	MinFilter= ANISOTROPIC;		// 異方性フィルタ（縮小時）
	//	MagFilter= ANISOTROPIC;		// 異方性フィルタ（拡大時）
};

//------------------------------------------------
// 頂点シェーダ
//------------------------------------------------
void AnimePaintVS(
	float3 in_Pos : POSITION,
	float3 in_Normal:NORMAL,
	float4 in_Color:COLOR,
	float2 in_Tex:TEXCOORD0,
 	out float4 out_Pos : POSITION,
	out float4 out_Color:COLOR0,
	out float2 out_Tex:TEXCOORD0,
	out float  out_ToonTex:TEXCOORD1
) 
{
	float4 P;
	// 座標変換
	P = mul(float4(in_Pos, 1.0f), g_world);
	out_Pos = mul(P, g_view);
	out_Pos = mul(out_Pos, g_projection);

	out_Tex = in_Tex;

	float3 N = normalize(in_Normal);
	float3 L = normalize(-g_light_dir - P.xyz);

	// トゥーンテクスチャU座標
	float U;
	U = dot(L, N) * 0.5f + 0.5f;
	U = max(0.0f,U);
	U = U * U;

	out_ToonTex = U;

	out_Color = g_ambient*g_ambient_mat + g_diffuse*g_diffuse_mat*U;
}

//------------------------------------------------
// ピクセルシェーダ
//------------------------------------------------
void AnimePaintPS(
	float4 in_Color:COLOR0,
	float2 in_Tex:TEXCOORD0,
	float in_ToonTex : TEXCOORD1,
	out float4 out_Color : COLOR0
)
{
	if(g_tex){
		float4 tex_color = tex2D(TextureSampler1, in_Tex);
			out_Color = tex_color*tex2D(ToonSampler1, float2(in_ToonTex, 0.0f));
		// テクスチャの色と頂点の色を掛け合わせる
	}
	else{
		out_Color = in_Color*tex2D(ToonSampler1, float2(in_ToonTex, 0.0f));
	}
}

//------------------------------------------------
// 頂点シェーダ
//------------------------------------------------
void LinePaintVS(
	float3 in_Pos : POSITION,
	float3 in_Normal : NORMAL,
	out float4 out_Pos : POSITION
	)
{
	float3 P;

	in_Normal = normalize(in_Normal);
	P = (float3)in_Pos + in_Normal * 0.03f;

	// 座標変換
	out_Pos = mul(float4(P, 1.0f), g_world);
	out_Pos = mul(out_Pos, g_view);
	out_Pos = mul(out_Pos, g_projection);
}

//------------------------------------------------
// ピクセルシェーダ
//------------------------------------------------
void LinePaintPS(
	out float4 out_Color : COLOR0
	)
{
	out_Color = float4(0,0,0,1);
}

//------------------------------------------------
// テクニック宣言
//------------------------------------------------
technique BasicTech
{
	pass P0
	{
		vertexShader = compile vs_3_0 LinePaintVS();
		pixelShader = compile ps_3_0 LinePaintPS();
	}

    pass P1
    {
		vertexShader = compile vs_3_0 AnimePaintVS();
		pixelShader = compile ps_3_0 AnimePaintPS();
	}
}
