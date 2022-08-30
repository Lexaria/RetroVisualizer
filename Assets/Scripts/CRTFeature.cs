using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CRTFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class PassSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        public Material material;
        [Range(1, 20)] public int NumOfBands = 5;

    }

    class TemplatePass : ScriptableRenderPass
    {
        public PassSettings settings;
        private RenderTargetIdentifier source;
        RenderTargetHandle tempTexture;

        private string profilerTag;

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
        }

        public TemplatePass(string profilerTag)
        {
            this.profilerTag = profilerTag;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cmd.GetTemporaryRT(tempTexture.id, cameraTextureDescriptor);
            ConfigureTarget(tempTexture.Identifier());

        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);
            cmd.Clear();
            source = renderingData.cameraData.renderer.cameraColorTarget;
            try
            {
                settings.material.SetInt("_NumOfBands", settings.NumOfBands);
                cmd.Blit(source, tempTexture.Identifier(), settings.material, 0);
                cmd.Blit(tempTexture.Identifier(), source);
                context.ExecuteCommandBuffer(cmd);
            }
            catch
            {
                Debug.LogError("Error");
            }

            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }
    }


// References to our pass and its settings.
    TemplatePass pass;
    public PassSettings passSettings = new();
    private RenderTargetHandle renderTargetHandle;


    public override void Create()
    {
        // Pass the settings as a parameter to the constructor of the pass.
        pass = new TemplatePass("CRT");
        name = "CRT";
        pass.settings = passSettings;
        pass.renderPassEvent = passSettings.renderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // Here you can queue up multiple passes after each other.
        var cameraColorTargetIdent = renderer.cameraColorTarget;
        pass.Setup(cameraColorTargetIdent);
        renderer.EnqueuePass(pass);
    }
}