using UnityEngine;

/// <summary>
/// Lua binding to manipulate in-game music and play sounds.
/// </summary>
public class MusicManager
{
    internal static AudioManager manager;

    public static float playtime
    {
        get
        {
            return manager.playtime;
        }
    }

    public static float totaltime
    {
        get
        {
            return manager.totaltime;
        }
    }

    public static void LoadFile(string name)
    {
		manager.PlayMusic(name,0);
	}

    public static void PlaySound(string name, float volume = 0.65f)
    {
		manager.PlaySound(name,volume);
	}

	public static void StartSound(string name, float volume = 0.65f, float fadeTime = 0)
	{
		manager.StartSound(name, volume,fadeTime);
	}

	public static void StopSound(string name, float fadeTime = 0)
	{
		manager.StopSound(name, fadeTime);
	}

	public static void FadeIn(float time)
	{
		manager.ActiveSource.FadeIn(time);
	}

	public static void FadeOut(float time)
	{
		manager.ActiveSource.FadeOut(time);
	}

    public static void Pitch(double value)
    {
		//Mathf.Clamp((float)value,-3,3);
		manager.pitch = (float)value;
    }

    public static void Volume(double value)
    {
        //Mathf.Clamp01((float)value);
        manager.basevolume = (float)value;
    }

	public static void Crossfade(string name, float time = 0.5f)
	{
		manager.PlayMusic(name, time, false);
	}

    public static void Play()
    {
		manager.Play();
    }

    public static void Stop()
    {
		manager.Stop();
    }

    public static void Pause()
    {
		manager.Pause();
    }

    public static void Unpause()
    {
		manager.UnPause();
    }
}