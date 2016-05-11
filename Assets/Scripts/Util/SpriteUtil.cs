using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;

using SpriteLayout;

using UnityEngine;
using UnityEngine.UI;

public static class SpriteUtil
{
    public const float PIXELS_PER_UNIT = 1.0f;
    public static void SwapSpriteFromFile(MonoBehaviour target, string filename)
    {
        try
        {
            Sprite newSprite = SpriteRegistry.Get(filename);
            if (newSprite == null)
            {
                newSprite = fromFile(FileLoader.pathToModFile("Sprites/" + filename + ".png"));
                SpriteRegistry.Set(filename, newSprite);
            }
            SpriteLayoutImage img = target.GetComponent<SpriteLayoutImage>();
            img.Sprite = newSprite;
            //enemyImg.SetNativeSize();
            img.ResetDimensions( newSprite.bounds.size);
        }
        catch (Exception e)
        {
            // TODO do something I guess
            Debug.LogError("Error loading sprite");
            Debug.LogException(e);
        }
    }

    //Xml variant
    public static void SwapSpriteFromFile(MonoBehaviour target, string filename, string spriteName)
    {
        try
        {
            Sprite newSprite = SpriteRegistry.Get(filename + "_" + spriteName);
            if (newSprite == null)
            {
                var sprites = fromFileXml(FileLoader.pathToModFile("Sprites/" + filename + ".png"));
                for (int i = 0; sprites != null && i < sprites.Length; ++i)
                {
                    SpriteRegistry.Set(filename+ "_" +sprites[i].name, sprites[i]);
                }
            }

            SpriteLayoutImage img = target.GetComponent<SpriteLayoutImage>();
            img.Sprite = newSprite;
            //enemyImg.SetNativeSize();
            img.ResetDimensions (newSprite.bounds.size);
        }
        catch (Exception e)
        {
            // TODO do something I guess
            Debug.LogError("Error loading sprite");
            Debug.LogException(e);
        }
    }

    public static Sprite spriteWithXml(XmlNode spriteNode, Sprite source)
    {
        XmlNode xmlRect = spriteNode.SelectSingleNode("rect");
        Rect spriteRect = new Rect(0, 0, source.texture.width, source.texture.height);
        if (xmlRect != null)
        {
            spriteRect = new Rect(
                int.Parse(xmlRect.Attributes["x"].Value),
                int.Parse(xmlRect.Attributes["y"].Value),
                int.Parse(xmlRect.Attributes["w"].Value),
                int.Parse(xmlRect.Attributes["h"].Value)
                );
        }
        XmlNode xmlBorder = spriteNode.SelectSingleNode("border");
        Vector4 spriteBorder = Vector4.zero;
        if (xmlBorder != null)
        {
            spriteBorder = new Vector4(
                int.Parse(xmlBorder.Attributes["x"].Value),
                int.Parse(xmlBorder.Attributes["y"].Value),
                int.Parse(xmlBorder.Attributes["z"].Value),
                int.Parse(xmlBorder.Attributes["w"].Value)
                );
        }

        Sprite s = Sprite.Create(source.texture, spriteRect, new Vector2(0.5f, 0.5f), PIXELS_PER_UNIT, 0, SpriteMeshType.FullRect, spriteBorder);
        if (spriteNode.Attributes["name"] != null)
        {
            s.name = spriteNode.Attributes["name"].Value;
        }
        return s;
    }

    public static Sprite[] atlasFromXml(XmlNode sheetNode, Sprite source)
    {
        try
        {
            List<Sprite> tempSprites = new List<Sprite>();
            foreach (XmlNode child in sheetNode.ChildNodes)
            {
                if (child.Name.Equals("sprite"))
                {
                    //Sprite s = Sprite.Create(source.texture, 
                    Sprite s = spriteWithXml(child, source);
                    tempSprites.Add(s);
                }
            }

            return tempSprites.ToArray();
        }
        catch (Exception ex)
        {
            UnitaleUtil.displayLuaError("[XML document]", "One of the sprites' XML documents was invalid. This could be a corrupt or edited file.\n\n" + ex.Message);
            return null;
        }
    }

    public static Sprite fromFile(string filename)
    {
        Sprite newSprite = new Sprite();
        Texture2D SpriteTexture = new Texture2D(1, 1);
        SpriteTexture.LoadImage(FileLoader.getBytesFrom(filename));
        SpriteTexture.filterMode = FilterMode.Point;
        SpriteTexture.wrapMode = TextureWrapMode.Clamp;
        newSprite = Sprite.Create(SpriteTexture, new Rect(0, 0, SpriteTexture.width, SpriteTexture.height), new Vector2(0, 0), PIXELS_PER_UNIT);
        //optional XML loading
        FileInfo fi = new FileInfo(Path.ChangeExtension(filename, "xml"));
        if (fi.Exists)
        {
            XmlDocument xmld = new XmlDocument();
            xmld.Load(fi.FullName);
            if (xmld["spritesheet"] != null && xmld["spritesheet"].GetAttribute("type").Equals("single"))
            {
                return spriteWithXml(xmld["spritesheet"].FirstChild, newSprite);
            }
        }
        return newSprite;
    }

    public static Sprite[] fromFileXml(string filename)
    {
        Sprite newSprite = new Sprite();
        Texture2D SpriteTexture = new Texture2D(1, 1);
        SpriteTexture.LoadImage(FileLoader.getBytesFrom(filename));
        SpriteTexture.filterMode = FilterMode.Point;
        SpriteTexture.wrapMode = TextureWrapMode.Clamp;
        newSprite = Sprite.Create(SpriteTexture, new Rect(0, 0, SpriteTexture.width, SpriteTexture.height), new Vector2(0, 0), PIXELS_PER_UNIT);
        //definitive XML loading
        FileInfo fi = new FileInfo(Path.ChangeExtension(filename, "xml"));
        if (fi.Exists)
        {
            XmlDocument xmld = new XmlDocument();
            xmld.Load(fi.FullName);
            XmlElement sheet = xmld["spritesheet"];
            if (sheet != null && sheet.GetAttribute("type").Equals("multiple"))
            {
                //return spriteWithXml(xmld["spritesheet"].FirstChild, newSprite);
                return atlasFromXml(sheet, newSprite);
            }
        }
        //return newSprite;
        UnitaleUtil.displayLuaError("[XML document]", "You're trying to load a spritesheet, but no spritesheet was found.");
        return null;
    }

    public static LuaSpriteController MakeIngameSprite(string filename)
    {
        SpriteLayoutImage i = GameObject.Instantiate<SpriteLayoutImage>(SpriteRegistry.GENERIC_SPRITE_PREFAB);
        if (!string.IsNullOrEmpty(filename))
        {
            SwapSpriteFromFile(i, filename);
        }
        i.transform.SetParent(GameObject.Find("BelowArenaLayer").transform, true); //TODO layering
        return new LuaSpriteController(i);
    }

    public static LuaSpriteController MakeIngameSprite(string filename, string spritename)
    {
		SpriteLayoutImage i = GameObject.Instantiate<SpriteLayoutImage>(SpriteRegistry.GENERIC_SPRITE_PREFAB);
        if (!string.IsNullOrEmpty(filename) && !string.IsNullOrEmpty(spritename))
        {
            SwapSpriteFromFile(i, filename, spritename);
        }
        i.transform.SetParent(GameObject.Find("BelowArenaLayer").transform, true); //TODO layering
        return new LuaSpriteController(i);
    }
}