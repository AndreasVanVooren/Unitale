﻿using MoonSharp.Interpreter;
using UnityEngine;
using SpriteLayout;

public class LuaProjectile : Projectile
{
    internal Script owner; //TODO convert to ScriptWrapper, observe performance influence

    public override void OnStart()
    {
        //self.Dimensions = GetComponent<Image>().sprite.rect.size;
        //selfAbs.width = self.rect.width;
        //selfAbs.height = self.rect.height;
        //GetComponent<Image>().enabled = true;
        ((SpriteLayoutImage)self).RendererEnabled = true;
    }

    public void setSprite(string name)
    {
        SpriteUtil.SwapSpriteFromFile(this, name);
    }

    public override void OnUpdate()
    {
        // destroy projectiles outside of the screen
        /*if (!screen.Contains(self.position))
            BulletPool.instance.Requeue(this);*/
    }

    public override void OnProjectileHitPlayer()
    {
        if (owner.Globals["OnHit"] != null && owner.Globals.Get("OnHit") != null)
        {
            try
            {
                owner.Call(owner.Globals["OnHit"], this.ctrl);
            }
            catch (ScriptRuntimeException ex)
            {
                UnitaleUtil.displayLuaError("[wave script filename here]\n(should be a filename, sorry! missing feature)", ex.DecoratedMessage);
            }
        }
        else
        {
            PlayerController.instance.Hurt(3);
        }
    }

	public override void OnProjectileHitProjectile(Projectile other)
	{
		if (owner.Globals["OnHitProjectile"] != null && owner.Globals.Get("OnHitProjectile") != null)
		{
			try
			{
				owner.Call(owner.Globals["OnHitProjectile"], this.ctrl, other.ctrl);
			}
			catch (ScriptRuntimeException ex)
			{
				UnitaleUtil.displayLuaError("[wave script filename here]\n(should be a filename, sorry! missing feature)", ex.DecoratedMessage);
			}
		}
		else
		{
			
		}
	}
}