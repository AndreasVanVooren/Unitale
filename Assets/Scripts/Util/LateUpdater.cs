using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Stopwatch = System.Diagnostics.Stopwatch;

/// <summary>
/// Stupid utility class that waits a frame before running whatever's inside because RectTransform's inherited positions aren't accurate on startup. Nice.
/// </summary>
public class LateUpdater : MonoBehaviour {
    public static List<Action> lateInit = new List<Action>();
    public static List<Action> lateActions = new List<Action>();
    int frametimer = 0;

    public static void init()
    {
        invokeList(lateInit);
    }
	
	void Update () {
        if (frametimer > 0)
        {
			Stopwatch sw = new Stopwatch(); //benchmarking terrible loading times
			sw.Start();
			invokeList(lateActions);
            Destroy(this);
			sw.Stop();
			Debug.Log("Late update actions: " + sw.ElapsedMilliseconds + "ms");
        }

        frametimer++;
	}

    private static void invokeList(List<Action> l){
        foreach(Action a in l){
            a.Invoke();
        }
        l.Clear();
    }
}
