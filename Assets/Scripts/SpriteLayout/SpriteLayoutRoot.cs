using UnityEngine;
using System.Collections;

namespace SpriteLayout
{
	[RequireComponent(typeof(Camera))]
	public class SpriteLayoutRoot : SpriteLayoutBase
	{
		public Camera SpriteCamera;

		public int PixelsPerUnit;

		#if UNITY_EDITOR
			const float timeBetweenUpdates = 0.1f;
		#elif UNITY_IOS || UNITY_ANDROID || UNITY_WINRT
			const float timeBetweenUpdates = 0.5f;
		#else
			const float timeBetweenUpdates = 0.0f;
		#endif
		// Use this for initialization
		void Start()
		{
			SpriteCamera = GetComponent<Camera>();

			#if UNITY_EDITOR || UNITY_IOS || UNITY_ANDROID || UNITY_WINRT
				StartCoroutine(UpdateLoop());
			#else
				UpdateFunc(); //do it once
			#endif
		}

		// UpdateLoop is called once per .1 seconds
		IEnumerator UpdateLoop()
		{
			for (;;)
			{
				UpdateFunc();
				yield return new WaitForSeconds(0.1f);
			}
		}

		void UpdateFunc() 
		{
			SpriteCamera.orthographicSize = Screen.height/(2 * PixelsPerUnit);

			this._initialDimensions = new Vector2(Screen.width/ PixelsPerUnit, Screen.height/ PixelsPerUnit);
			this.Dimensions = new Vector2(Screen.width/ PixelsPerUnit, Screen.height/ PixelsPerUnit);
		}
	}
}
