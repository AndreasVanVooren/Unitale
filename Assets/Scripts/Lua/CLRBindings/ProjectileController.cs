﻿using System.Collections.Generic;
using MoonSharp.Interpreter;
using UnityEngine;

/// <summary>
/// Lua binding to set and retrieve information for bullets in the game.
/// </summary>
public class ProjectileController
{
    bool active = true;
    private Projectile p;
    private LuaSpriteController spr;
    private Dictionary<string, DynValue> vars = new Dictionary<string, DynValue>();

    public ProjectileController(Projectile p)
    {
        this.p = p;
        this.spr = new LuaSpriteController(p.GetComponent<SpriteLayout.SpriteLayoutImage>());
    }

    public float x
    {
        get;
        internal set;
    }

    public float y
    {
        get;
        internal set;
    }

    /*
     * not quite working due to unity's UI layering system
     * public float z
    {
        get
        {
            return p.self.position.z;
        }
        internal set
        {
            p.self.position = new Vector3(p.self.position.x, p.self.position.y, value);
        }
    }*/

    public float absx
    {
        get;
        internal set;
    }

    public float absy
    {
        get;
        internal set;
    }

    public bool isactive
    {
        get
        {
            return active;
        }
    }

	public bool canCollideWithProjectiles
	{
		get { return p.canCollideWithOtherProjectiles; }
		set { p.canCollideWithOtherProjectiles = value; }
	}

    public LuaSpriteController sprite
    {
        get
        {
            return spr;
        }
    }

    public void UpdatePosition()
    {
        this.x = p.self.LocalPosition.x - ArenaSizer.arenaCenter.x;
        this.y = p.self.LocalPosition.y - ArenaSizer.arenaCenter.y;
        this.absx = p.self.LocalPosition.x;
        this.absy = p.self.LocalPosition.y;
    }

	public void SetRectColliderSize(float x, float y)
	{
		var coll = p.self.GetComponent<BoxCollider2D>();
		if (coll == null)
		{
			UnitaleUtil.displayLuaError("", "Projectile has no rect collider");
		}

		coll.size = new Vector2(x,y);
	}

	public void SetCircleColliderSize(float r)
	{
		Debug.Log("bAy lmao");
		var coll = p.self.GetComponent<CircleCollider2D>();
		if(coll == null)
		{
			UnitaleUtil.displayLuaError("", "Projectile has no circle collider");
		}

		coll.radius = r;
	}

	public void SetColliderOffset(float x, float y)
	{
		Debug.LogFormat("Ay lmao {0}, {1}",x,y);
		var coll = p.self.GetComponent<Collider2D>();
		if (coll == null)
		{
			UnitaleUtil.displayLuaError("", "Projectile has no collider");
		}

		coll.offset = new Vector2(x, y);
	}

	public void SetCollider(string type)
	{
		var image = ((SpriteLayout.SpriteLayoutImage)p.self);
		if (image == null)
		{
			UnitaleUtil.displayLuaError("", "Projectile has no image part");
		}
		if (type.ToLower() == "rect")
		{
			image.RemoveColliders();
			image.AttachCollider(SpriteLayout.ColliderType.Rect);
		}
		else if (type.ToLower() == "circle")
		{
			image.RemoveColliders();
			image.AttachCollider(SpriteLayout.ColliderType.Circle);
		}
		else
		{
			UnitaleUtil.displayLuaError("", "SetCollider: type has to be either \"rect\" or \"circle\"");
		}
	}

	public void SetCircleCollider(float rad = 1.0f,float xOff = 0.0f, float yOff = 0.0f)
	{
		var image = ((SpriteLayout.SpriteLayoutImage)p.self);
		if (image == null)
		{
			UnitaleUtil.displayLuaError("", "Projectile has no image part");
		}
		image.RemoveColliders();
		image.AttachCircleCollider(xOff, yOff, rad);
	}

	public void SetRectCollider(float xSize = 1.0f, float ySize = 1.0f, float xOff = 0.0f, float yOff = 0.0f)
	{
		var image = ((SpriteLayout.SpriteLayoutImage)p.self);
		if (image == null)
		{
			UnitaleUtil.displayLuaError("", "Projectile has no image part");
		}
		image.RemoveColliders();
		image.AttachRectCollider(xOff,yOff,xSize, ySize);
	}

	public void Remove()
    {
        if (active)
        {
            BulletPool.instance.Requeue(p);
            this.p = null;
            active = false;
        }
    }

    public void Move(float x, float y)
    {
        MoveToAbs(p.self.LocalPosition.x + x, p.self.LocalPosition.y + y);
    }

    public void MoveTo(float x, float y)
    {
        MoveToAbs(ArenaSizer.arenaCenter.x + x, ArenaSizer.arenaCenter.y + y);
    }

    public void MoveToAbs(float x, float y)
    {
        if (p == null)
        {
            throw new MoonSharp.Interpreter.ScriptRuntimeException("Attempted to move a removed bullet. You can use a bullet's isactive property to check if it has been removed.");
        }
        p.self.LocalPosition = new Vector2(x, y);
    }

    public void SendToTop()
    {
        //p.self.SetAsLastSibling(); // in unity, the lowest UI component in the hierarchy renders last
        ((SpriteLayout.SpriteLayoutImage)p.self).SendToTop();
    }

    public void SendToBottom()
    {
        //p.self.SetAsFirstSibling();
        ((SpriteLayout.SpriteLayoutImage)p.self).SendToBottom();
    }

    public void SetVar(string name, DynValue value)
    {
        vars[name] = value;
    }

    public DynValue GetVar(string name)
    {
        DynValue retval;
        if (vars.TryGetValue(name, out retval))
        {
            return retval;
        }
        else
        {
            return null;
        }
    }
}