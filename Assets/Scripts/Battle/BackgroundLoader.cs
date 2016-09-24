using System;
using UnityEngine;
using SpriteLayout;

/// <summary>
/// Extremely lazy background loader which is only slightly better than not having a background.
/// Currently attempts to load the 'bg' file from the Sprites folder, otherwise does nothing.
/// Attached to the Background object in the Battle scene.
/// </summary>
public class BackgroundLoader : MonoBehaviour
{
    SpriteLayoutImage bgImage;
    // Use this for initialization
    private void Start()
    {
        bgImage = GetComponent<SpriteLayoutImage>();
        try
        {
            Sprite bg = SpriteUtil.fromFile(FileLoader.pathToModFile("Sprites/bg.png"));
            if (bg != null)
            {
                bg.texture.filterMode = FilterMode.Point;
                bgImage.Sprite = bg;
                bgImage.Color = Color.white;
            }
        }
        catch (Exception e)
        {
            // background failed loading, no need to do anything
            Debug.Log("No background file found. Using empty background.");
        }
    }
}