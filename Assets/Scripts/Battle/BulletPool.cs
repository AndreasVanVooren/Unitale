﻿using System.Collections.Generic;
using UnityEngine;
using SpriteLayout;
using System.Collections;
using System.Diagnostics;
using Debug = UnityEngine.Debug;

/// <summary>
/// The bullet pool where Projectiles are drawn from for performance reasons.
/// </summary>
public class BulletPool : MonoBehaviour
{
    public static BulletPool instance;
    public static int POOLSIZE = 100;
    private static Queue<Projectile> pool = new Queue<Projectile>();
    private static Projectile bPrefab; // bullet prefab
    private static int currentProjectile = 0;

    /// <summary>
    /// Initialize the pool with POOLSIZE Projectiles ready to go
    /// </summary>
    private void Start()
    {
		Stopwatch watch = new Stopwatch(); //benchmarking terrible loading times
		watch.Start();
		instance = this;
        bPrefab = Resources.Load<LuaProjectile>("Prefabs/LUAProjectile");
        pool.Clear();
        for (int i = 0; i < POOLSIZE; i++)
        {
            createPooledBullet();
        }
		watch.Stop();
		Debug.Log("Projectile pool creation time: " + watch.ElapsedMilliseconds + "ms");
	}

    /// <summary>
    /// Creates a new Projectile and adds it to the pool. Used during instantion and when the pool is empty.
    /// </summary>
    private void createPooledBullet()
    {
        Projectile lp = Instantiate(bPrefab);
        lp.transform.SetParent(transform);
        lp.GetComponent<SpriteLayoutBase>().Position = new Vector2(-999, -999); // move offscreen to be safe, but shouldn't be necessary
        pool.Enqueue(lp);
        lp.gameObject.SetActive(false);
    }

    /// <summary>
    /// Retrieve a Projectile from the pool, or create a new one if it's empty.
    /// </summary>
    /// <returns>A Projectile object for further modification.</returns>
    public Projectile Retrieve()
    {
        if (pool.Count == 0)
            createPooledBullet();
        Projectile dq = pool.Dequeue(); // had some other stuff going on
        dq.renewController();
        return dq;
    }

    /// <summary>
    /// Return a projectile to the pool.
    /// </summary>
    /// <param name="p">Projectile to return</param>
    public void Requeue(Projectile p)
    {
        p.GetComponent<SpriteLayoutBase>().Position = new Vector2(-999, -999);
        p.gameObject.SetActive(false);
        pool.Enqueue(p);
    }
}