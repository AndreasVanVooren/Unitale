using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;
using SpriteLayout;

public class LuaSpriteController {
    private SpriteLayoutImage _img;
    internal SpriteLayoutImage img { 
        get {
            if (_img == null)
            {
                throw new MoonSharp.Interpreter.ScriptRuntimeException("Attempted to perform action on removed sprite.");
            }
            else
            {
                return _img;
            }
        }
        set { _img = value; }
    }
    //private Vector2 nativeSizeDelta;
    //private Vector3 internalRotation = Vector3.zero;
    private float xScale = 1.0f;
    private float yScale = 1.0f;
    private Sprite originalSprite;
    private KeyframeCollection keyframes;

    private List<LuaSpriteController> children = new List<LuaSpriteController>();
    private LuaSpriteController parent;

    public float x
    {
        get { return img.LocalPosition.x; }
        set { img.LocalPosition = new Vector2(value, img.LocalPosition.y); }
    }

    public float y
    {
        get { return img.LocalPosition.y; }
        set { img.LocalPosition = new Vector2(img.LocalPosition.x, value); }
    }

	public float xAbs
	{
		get { return img.Position.x; }
        set { img.Position = new Vector2(value, img.Position.y); }
	}

	public float yAbs
	{
        get { return img.Position.y; }
        set { img.Position = new Vector2(img.Position.x, value); }
	}

	public float absx
	{
		get { return xAbs; }
		set { xAbs = value; }
	}

	public float absy
	{
		get { return yAbs; }
		set { yAbs = value; }
	}

	public float xscale
    {
        get { return xScale; }
        set { 
            xScale = value; 
            Scale(xScale, yScale); 
        }
    }

    public float yscale
    {
        get { return yScale; }
        set { 
            yScale = value; 
            Scale(xScale, yScale); 
        }
    }

    public bool isactive
    { 
        get { return _img == null; } 
    }

    public float width
    {
        get { return img.Width; }
    }

    public float height
    {
        get { return img.Height; }
    }

    internal bool animcomplete
    {
        get
        {
            if (keyframes != null)
            {
                return keyframes.enabled && keyframes.animationComplete();
            }
            return false;
        }
    }

    internal KeyframeCollection.LoopMode loop
    {
        get
        {
            return keyframes.loop;
        }
        set
        {
            keyframes.loop = value;
        }
    }

    public float[] color {
        get { return new float[] { img.Color.r, img.Color.g, img.Color.b }; }
        set {
            if (value.Length != 3)
            {
                throw new MoonSharp.Interpreter.ScriptRuntimeException("You need 3 numeric values when setting a sprite's color.");
            }
            else
            {
                img.Color = new Color(value[0], value[1], value[2]);

            }
        }
    }

    public float alpha
    {
        get { return img.Color.a; }
        set
        {
            float valClamped = Mathf.Clamp01(value);
            img.Color = new Color(img.Color.r, img.Color.g, img.Color.b, valClamped);
        }
    }

    public float rotation
    {
        get { return img.EulerAngles.z; }
        set {
			//var zDiff = img.EulerAngles.z - value;
			var euler = img.EulerAngles;
			euler.z = Math.mod(value, 360);
			img.EulerAngles = euler;
			//img.rectTransform.localEulerAngles = internalRotation;
		}
    }

	public float localRotation
	{
        get { return img.LocalEulerAngles.z; }
		set
		{
			var euler = img.LocalEulerAngles;
			euler.z = Math.mod(value, 360);
			img.LocalEulerAngles = euler;
			//img.LocalRotation = internalRotation;
		}
	}

	/*
    public bool filter
    {
        get { return img.sprite.texture.filterMode != FilterMode.Point; }
        set
        {
            if (value)
            {
                img.sprite.texture.filterMode = FilterMode.Trilinear;
            }
            else
            {
                img.sprite.texture.filterMode = FilterMode.Point;
            }
        }
    }
    */

	public LuaSpriteController(SpriteLayoutImage i)
    {
        this.img = i;
        originalSprite = img.Sprite;
        //nativeSizeDelta = img.Dimensions;


		//BUG : Recreated bullets are still animated
		keyframes = img.gameObject.GetComponent<KeyframeCollection>();
		if (keyframes == null)
		{
			//disable the keyframe collection;
			keyframes = img.gameObject.AddComponent<KeyframeCollection>();
			keyframes.spr = this;
			//Debug.Log("Lol");
		}
		keyframes.enabled = false;
		//Debug.Log("Created thing with size delta " + nativeSizeDelta.ToString());
	}

	// causes the controller to reset its values, ensuring the correct values are used as native width/height
	public void Reset()
	{
		originalSprite = img.Sprite;
		//nativeSizeDelta = img.Dimensions;

		keyframes = img.gameObject.GetComponent<KeyframeCollection>();
		if (keyframes == null)
		{
			//disable the keyframe collection;
			keyframes = img.gameObject.AddComponent<KeyframeCollection>();
			keyframes.spr = this;
			//Debug.Log("Lol");
		}
		keyframes.enabled = false;
	}

	public void Set(string name)
    {
        SpriteUtil.SwapSpriteFromFile(img, name);
        originalSprite = img.Sprite;
        //nativeSizeDelta = new Vector2(img.sprite.texture.width, img.sprite.texture.height);
        Scale(xScale, yScale);
    }

    public void Set(string name, string sprName)
    {
        SpriteUtil.SwapSpriteFromFile(img, name, sprName);
        originalSprite = img.Sprite;
        //nativeSizeDelta = new Vector2(img.sprite.texture.width, img.sprite.texture.height);
        Scale(xScale, yScale);
    }

    public void SetParent(LuaSpriteController parent)
    {
        img.SetParent(parent.img.transform);
        //remove child from previous parent
        if(this.parent != null)
            this.parent.children.Remove(this);
        this.parent = parent;
        //add child to new parent
        parent.children.Add(this);
    }

    public void SetPivot(float x, float y)
    {
        img.Pivot = new Vector2(x, y);
    }

    public void SetAnchor(float x, float y){
        img.Anchor = new Vector2(x, y);
    }

    public void Scale(float xs, float ys, bool alsoScaleChildren = false)
    {
        //xScale = xs;
        //yScale = ys;
        //img.rectTransform.sizeDelta = new Vector2(nativeSizeDelta.x * xScale, nativeSizeDelta.y * yScale);
		//Debug.LogFormat ("Scaling : size = {0}, scale children = {1}, transform scale : {2}", img.rectTransform.sizeDelta, alsoScaleChildren, img.transform.localScale);

        img.LocalScale = new Vector2(xs, ys);
        //Debug.LogFormat ("Scaling : size = {0}, scale children = {1}, transform scale : {2}", img.LocalScale, alsoScaleChildren, img.transform.localScale);
		if(!alsoScaleChildren)
		{

			for (int i = 0; i < children.Count; i++)
			{
				//Debug.Log("Scaling child");
				children[i].Scale(1/xs, 1/ys,false);
			}
		}
    }

    public void SetAnimation(string[] frames)
    {
        SetAnimation(frames, 1 / 30f);
    }

    public void SetAnimation(string[] spriteNames, float frametime)
    {
        Keyframe[] kfArray = new Keyframe[spriteNames.Length];
        for (int i = 0; i < spriteNames.Length; i++)
        {
            kfArray[i] = new Keyframe(SpriteRegistry.Get(spriteNames[i]));
        }
        if (keyframes == null)
        {
            keyframes = img.gameObject.AddComponent<KeyframeCollection>();
            keyframes.spr = this;
        }
        else
        {
            keyframes.enabled = true;
        }
        
        keyframes.Set(kfArray, frametime);
    }

    public void StopAnimation()
    {
        if (keyframes != null)
        {
            keyframes.enabled = false;
            img.Sprite = originalSprite;
        }
    }

    public void MoveTo(float x, float y)
    {
        img.LocalPosition = new Vector2(x, y);
    }

    public void MoveToAbs(float x, float y)
    {
        img.Position = new Vector2(x, y);
    }

    public void SendToTop()
    {
        //Debug.Log("[LuaSpriteController::SendToTop] TODO");
		//img.rectTransform.SetAsLastSibling(); // in unity, the lowest UI component in the hierarchy renders last
		img.SendToTop();
	}

    public void SendToBottom()
    {
        //Debug.Log("[LuaSpriteController::SendToBottom] TODO");
		img.SendToBottom();
        //img.rectTransform.SetAsFirstSibling();
    }

    public void SetSortOrder(int orderVal)
    {
        
    }

    public void Remove()
    {
        GameObject.Destroy(img.gameObject);
		parent.children.Remove(this);
		this.parent = null;
		img = null;
    }

    internal void UpdateAnimation()
    {
        if (keyframes == null)
        {
            return;
        }
        Keyframe k = keyframes.getCurrent();
        Sprite s = SpriteRegistry.GENERIC_SPRITE_PREFAB.Sprite;
        
        if (k != null)
        {
            s = k.sprite;
        }

        if (img.Sprite != s)
        {
			img.Sprite = s;
        }
    }

    void Update(){
        UpdateAnimation();
    }
}
