using UnityEngine;
using System.Collections.Generic;

public class AudioManager : MonoBehaviour
{
	[HideInInspector]
	public AudioFader MusicSource1;
	[HideInInspector]
	public AudioFader MusicSource2;
	bool usingSecondary = true;	//set to true so it will be set to false when the game starts
	public AudioFader ActiveSource 
	{ 
		get 
		{
			if (usingSecondary) return MusicSource2;
			else return MusicSource1;
		} 
	}

	public float playtime { get { return ActiveSource.src.time; } }
	public float totaltime { get { return ActiveSource.src.clip.length; } }
	public float basevolume { get { return ActiveSource.baseVolume; } set { MusicSource1.baseVolume = value; MusicSource2.baseVolume = value; } }
	public float volume { get { return ActiveSource.src.volume; } }
	public float pitch { get { return ActiveSource.src.pitch; } set { MusicSource1.src.pitch = value; MusicSource2.src.pitch = value; } }

	public void PlayMusic(string name, float fadeTime = 0, bool disableStoppedTrack = true)
	{
		ActiveSource.deactivateAfterFadeOut = disableStoppedTrack;
		ActiveSource.FadeOut(fadeTime);

		usingSecondary = !usingSecondary;

		var clip = AudioClipRegistry.GetMusic(name);
		if(ActiveSource.src.clip != clip)
		{
			ActiveSource.src.clip = clip;
		}
		ActiveSource.FadeIn(fadeTime);
	}


	Queue<AudioFader> LoopUnits = new Queue<AudioFader>();
	Dictionary<string, AudioFader> ActiveLoops = new Dictionary<string, AudioFader>();
	const int POOL_AMOUNT = 10;
	// Use this for initialization
	void Awake()
	{
		AllocateMoreUnits();

		var go = new GameObject("Primary Music Source");
		go.transform.SetParent(this.transform);
		MusicSource1 = go.AddComponent<AudioFader>();

		MusicSource1.src.loop = true;
		MusicSource1.src.playOnAwake = true;
		MusicSource1.enabled = true;
		MusicSource1.deactivateAfterFadeOut = false;
		
		var go2 = new GameObject("Secondary Music Source");
		go2.transform.SetParent(this.transform);
		MusicSource2 = go2.AddComponent<AudioFader>();

		MusicSource2.src.loop = true;
		MusicSource2.src.playOnAwake = true;
		MusicSource2.enabled = true;
		MusicSource2.deactivateAfterFadeOut = false;
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

	public AudioFader GetSound(string sound)
	{
		AudioFader fader = null;
		if(ActiveLoops.TryGetValue(sound,out fader))
		{
			return fader;
		}
		return null;
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
		ActiveSource.src.Play();
	}
	public void Stop()
	{
		ActiveSource.src.Stop();
	}
	public void Pause()
	{
		ActiveSource.src.Pause();
	}
	public void UnPause()
	{
		ActiveSource.src.UnPause();
	}
}
