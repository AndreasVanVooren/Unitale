using UnityEngine;
using System.Collections;

namespace SpriteLayout
{

	[RequireComponent(typeof(Camera))]
	public class SpriteLayoutRoot : SpriteLayoutBase
	{
		public Camera SpriteCamera;

        [Range(1,10000)]
		public int PixelsPerUnit = 1;

		#if UNITY_EDITOR
			const float timeBetweenUpdates = 0.1f;
		#elif UNITY_IOS || UNITY_ANDROID || UNITY_WINRT //tablet devices
			const float timeBetweenUpdates = 0.5f;
		#else
			const float timeBetweenUpdates = 0.0f;
		#endif
		// Use this for initialization

        internal override void Initialize()
        {
            base.Initialize();
            
            SpriteCamera = GetComponent<Camera>();

            #if UNITY_EDITOR || UNITY_IOS || UNITY_ANDROID || UNITY_WINRT   //editor or rotatable mobile platform
                StartCoroutine(UpdateLoop());
            #else
                UpdateFunc(); //do it once
            #endif
        }

		void Awake()
		{
			Initialize();

			//if (StaticInits.Initialized)
			//{
			//	ResetTransform();
			//}
			//else
			//{
			//	LateUpdater.lateActions.Add(ResetTransform);
			//}
		}

		void Start()
		{
			
		}

		void Update()
		{
			ResetTransform();
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
            if (PixelsPerUnit == 0)
            {
                Debug.LogError("Pixels per unit of canvas is 0");
                return;
            }

			SpriteCamera.orthographicSize = Screen.height/(2 * PixelsPerUnit);

			this._initialDimensions = new Vector2(Screen.width/ PixelsPerUnit, Screen.height/ PixelsPerUnit);
			this.Dimensions = new Vector2(Screen.width/ PixelsPerUnit, Screen.height/ PixelsPerUnit);
		}
	}
}
