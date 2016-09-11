using UnityEngine;
using System.Collections.Generic;

public class AudioManager : MonoBehaviour
{
	[HideInInspector]
	public AudioFader MusicSource;
	public float playtime { get { return MusicSource.src.time; } }
	public float totaltime { get { return MusicSource.src.clip.length; } }
	public float basevolume { get { return MusicSource.baseVolume; } set { MusicSource.baseVolume = value; } }
	public float volume { get { return MusicSource.src.volume; } }
	public float pitch { get { return MusicSource.src.pitch; } set { MusicSource.src.pitch = value; } }

	public void PlayMusic(string name)
	{
		MusicSource.src.Stop();
		MusicSource.src.clip = AudioClipRegistry.GetMusic(name);
		MusicSource.src.Play();
	}

	Queue<AudioFader> LoopUnits = new Queue<AudioFader>();
	Dictionary<string, AudioFader> ActiveLoops = new Dictionary<string, AudioFader>();
	const int POOL_AMOUNT = 10;
	// Use this for initialization
	void Start()
	{
		AllocateMoreUnits();
		MusicSource.deactivateAfterFadeOut = false;
	}

	void AllocateMoreUnits()
	{
		for (int i = 0; i < POOL_AMOUNT; i++)
		{
			var go = new GameObject("LoopUnit");
			go.transform.SetParent(this.transform);
			var src = go.AddComponent<AudioFader>();
			
			src.src.loop = true;
			src.src.playOnAwake = true;
			src.enabled = false;
			LoopUnits.Enqueue(src);
		}
	}

	public void StartSound(string sound,float vol, float fadeTime = 0)
	{
		if(LoopUnits.Count <= 0)
		{
			AllocateMoreUnits();
		}
		var src = LoopUnits.Dequeue();
		
		src.deactivateAfterFadeOut = false;
		src.enabled = true;
		src.src.Stop();
		src.src.clip = AudioClipRegistry.GetSound(sound);
		src.src.Play();
		src.baseVolume = vol;
		src.FadeIn(fadeTime);
		ActiveLoops.Add(sound, src);
	}

	public void StopSound(string sound, float fadeTime = 0)
	{
		AudioFader fader;
		if(ActiveLoops.TryGetValue(sound, out fader))
		{
			//fader.src.Stop();
			fader.FadeOut(fadeTime);
			fader.deactivateAfterFadeOut = true;
			LoopUnits.Enqueue(fader);
			//fader.gameObject.SetActive(false);
			ActiveLoops.Remove(sound);
		}
	}

	public void StartMusicAsSound(string sound,float vol, float fadeTime = 0)
	{
		if (LoopUnits.Count <= 0)
		{
			AllocateMoreUnits();
		}
		var src = LoopUnits.Dequeue();

		src.deactivateAfterFadeOut = false;
		src.enabled = true;
		src.src.Stop();
		src.src.clip = AudioClipRegistry.GetMusic(sound);
		src.src.Play();
		src.baseVolume = vol;
		src.FadeIn(fadeTime);
		ActiveLoops.Add(sound, src);
	}

	public void PlaySound(string name, float volume = 0.65f)
	{
		AudioSource.PlayClipAtPoint(AudioClipRegistry.GetSound(name), Camera.main.transform.position, volume);
	}
	
	public void Play()
	{
		MusicSource.src.Play();
	}
	public void Stop()
	{
		MusicSource.src.Stop();
	}
	public void Pause()
	{
		MusicSource.src.Pause();
	}
	public void UnPause()
	{
		MusicSource.src.UnPause();
	}
}
