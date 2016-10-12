//------------------------------------------------
// �O���[�o���ϐ�
//------------------------------------------------

float4x4	g_world;					// ���[���h�ϊ��s��
float4x4 	g_view;						// �J�����ϊ��s��
float4x4 	g_projection;				// �v���W�F�N�V�����ϊ��s��

texture		g_toon;
texture		g_texture;					// �e�N�X�`��
bool		g_tex;						// �e�N�X�`���̂���Ȃ��@false:�Ȃ��@true:����

// ��
float4		g_diffuse;					// �f�B�t���[�Y
float4		g_emmisive;					// �G�~�b�V�u
float4		g_ambient;					// ����
float4		g_specular;					// �X�y�L�����[��

float3		g_light_dir;				// ���s�����̕���

// �}�e���A��
float4		g_diffuse_mat;				// �f�B�t���[�Y��
float4		g_emmisive_mat;				// �G�~�b�V�u��
float4		g_ambient_mat;				// ����
float4		g_specular_mat;				// �X�y�L�����[
float		g_power;					// �X�y�L�����[���̃p���[�l
float4		g_camerapos;				// �J�����ʒu


//------------------------------------------------
// �T���v���[1
//------------------------------------------------
sampler TextureSampler1 =
sampler_state{
	Texture = <g_texture>;
	MinFilter= LINEAR;		// ���j�A�t�B���^�i�k�����j
	MagFilter= LINEAR;		// ���j�A�t�B���^�i�g�厞�j
//	MinFilter= POINT;		// �t�B���^�������Ȃ�
//	MagFilter= POINT;		// �t�B���^�������Ȃ�
//	MinFilter= ANISOTROPIC;		// �ٕ����t�B���^�i�k�����j
//	MagFilter= ANISOTROPIC;		// �ٕ����t�B���^�i�g�厞�j
};

sampler ToonSampler1 =
sampler_state{
	Texture = <g_toon>;
	MinFilter = LINEAR;		// ���j�A�t�B���^�i�k�����j
	MagFilter = LINEAR;		// ���j�A�t�B���^�i�g�厞�j
	//	MinFilter= POINT;		// �t�B���^�������Ȃ�
	//	MagFilter= POINT;		// �t�B���^�������Ȃ�
	//	MinFilter= ANISOTROPIC;		// �ٕ����t�B���^�i�k�����j
	//	MagFilter= ANISOTROPIC;		// �ٕ����t�B���^�i�g�厞�j
};

//------------------------------------------------
// ���_�V�F�[�_
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
	// ���W�ϊ�
	P = mul(float4(in_Pos, 1.0f), g_world);
	out_Pos = mul(P, g_view);
	out_Pos = mul(out_Pos, g_projection);

	out_Tex = in_Tex;

	float3 N = normalize(in_Normal);
	float3 L = normalize(-g_light_dir - P.xyz);

	// �g�D�[���e�N�X�`��U���W
	float U;
	U = dot(L, N) * 0.5f + 0.5f;
	U = max(0.0f,U);
	U = U * U;

	out_ToonTex = U;

	out_Color = g_ambient*g_ambient_mat + g_diffuse*g_diffuse_mat*U;
}

//------------------------------------------------
// �s�N�Z���V�F�[�_
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
		// �e�N�X�`���̐F�ƒ��_�̐F���|�����킹��
	}
	else{
		out_Color = in_Color*tex2D(ToonSampler1, float2(in_ToonTex, 0.0f));
	}
}

//------------------------------------------------
// ���_�V�F�[�_
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

	// ���W�ϊ�
	out_Pos = mul(float4(P, 1.0f), g_world);
	out_Pos = mul(out_Pos, g_view);
	out_Pos = mul(out_Pos, g_projection);
}

//------------------------------------------------
// �s�N�Z���V�F�[�_
//------------------------------------------------
void LinePaintPS(
	out float4 out_Color : COLOR0
	)
{
	out_Color = float4(0,0,0,1);
}

//------------------------------------------------
// �e�N�j�b�N�錾
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
