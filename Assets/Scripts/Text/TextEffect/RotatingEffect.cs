﻿using UnityEngine;
using SpriteLayout;

public class RotatingEffect : TextEffect
{
    private float sinTimer;
    private float intensity;
    private float rotSpeed = 7.0f;

    public RotatingEffect(TextManager textMan, float intensity = 1.5f)
        : base(textMan)
    {
        this.intensity = intensity;
    }

    protected override void updateInternal()
    {
        for (int i = 0; i < textMan.letterReferences.Length; i++)
        {
            if (textMan.letterReferences[i] == null)
                continue;
			SpriteLayoutBase rt = textMan.letterReferences[i].GetComponent<SpriteLayoutBase>();
            float iDiv = sinTimer * rotSpeed + (i / 3.0f);
            rt.LocalPosition = new Vector2(textMan.letterPositions[i].x + intensity * -Mathf.Sin(iDiv), textMan.letterPositions[i].y + intensity * Mathf.Cos(iDiv));
        }

        sinTimer += Time.deltaTime;
    }
}