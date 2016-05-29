#pragma warning disable 0649

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using SpriteLayout;

/// <summary>
/// Behaviour that retrieves resources from the built-in registry rather than setting them on the components in the Unity Editor.
/// </summary>
class AutoloadResourcesFromRegistry : MonoBehaviour
{
    [Header("Image Resource")]
    public bool SetNativeSize;
    public string SpritePath;
    [Header("Audio Resource")]
    public bool Loop;
    public string SoundPath;

    void Awake()
    {
        if (StaticInits.Initialized)
        {
            LateStart();
        }
        else
        {
            LateUpdater.lateInit.Add(LateStart);
        }
    }

    void LateStart()
    {
        if(!string.IsNullOrEmpty(SpritePath)){
            SpriteLayoutImage img = GetComponent<SpriteLayoutImage>();
            if (img != null)
            {
                img.Sprite = SpriteRegistry.Get(SpritePath);
                if (SetNativeSize)
                {
                    img.Dimensions = img.Sprite.bounds.size;
                }
            }

            ParticleSystem psys = GetComponent<ParticleSystem>();
            if (psys != null)
            {
                ParticleSystemRenderer prender = GetComponent<ParticleSystemRenderer>();
                prender.material.mainTexture = SpriteRegistry.Get(SpritePath).texture;
            }
        }

        if(!string.IsNullOrEmpty(SoundPath)){
            AudioSource aSrc = GetComponent<AudioSource>();
            aSrc.clip = AudioClipRegistry.Get(SoundPath);
            aSrc.loop = Loop;
        }
    }
}
