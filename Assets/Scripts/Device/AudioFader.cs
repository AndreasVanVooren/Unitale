using UnityEngine;
using System.Collections;

[RequireComponent(typeof(AudioSource))]
public class AudioFader : MonoBehaviour
{
	[HideInInspector]
	public AudioSource src;
	public float fadeAlpha { get; private set; }
	public bool isFadingIn { get; private set; }
	public bool isFadingOut { get { return !isFadingIn; } private set { isFadingIn = !value; } }
	public float fadeTimer { get; private set; }
	public float fadeTime { get; private set; }
	public float fadeDelay { get; private set; }
	public float baseVolume = 1.0f;
	public bool deactivateAfterFadeOut = true;

	public void FadeIn(float time, float delay = 0)
	{
		isFadingIn = true;
		enabled = true;
		if (fadeTime >= fadeTimer)
		{
			fadeDelay = delay;
		}
		if(!src.isPlaying)
		{
			src.Play();
		}

		fadeTimer = time;
		fadeTime = (fadeAlpha) * fadeTimer;
		if (time == 0)
		{
			fadeAlpha = 1;
			fadeTime = 1;
		}

	}

	public void FadeOut(float time, float delay = 0)
	{
		isFadingIn = false;
		if (fadeAlpha >= 1.0f || fadeAlpha <= 0.0f)
		{
			fadeDelay = delay;
		}

		fadeTimer = time;
		fadeTime = (1 - fadeAlpha) * fadeTimer;
		if (time == 0)
		{
			fadeAlpha = 0;
			fadeTime = 1;
		}
	}

	public void Awake()
	{
		src = GetComponent<AudioSource>();
		fadeAlpha = 1;
		fadeTime = 1;
		fadeTimer = 1;
		isFadingIn = true;
	}

	public void Update()
	{
		if (fadeDelay > 0)
		{
			fadeDelay -= Time.deltaTime;
			return;
		}

		fadeTime += Time.deltaTime;

		if (fadeTime >= fadeTimer)
		{
			if(isFadingOut && deactivateAfterFadeOut)
			{
				enabled = false;
				return;
			}
		}

		if (fadeTimer == 0) 
		{
			src.volume = isFadingIn ? baseVolume : 0;
			return;
		}
		fadeAlpha = Mathf.Clamp01(fadeTime / fadeTimer);

		if (isFadingOut)
		{
			fadeAlpha = 1 - fadeAlpha;
		}

		src.volume = baseVolume * fadeAlpha;
	}

	void OnEnable()
	{
		if(!src)
		{
			src = GetComponent<AudioSource>();
		}

		src.enabled = true;
	}
	void OnDisable()
	{
		src.enabled = false;
	}
}