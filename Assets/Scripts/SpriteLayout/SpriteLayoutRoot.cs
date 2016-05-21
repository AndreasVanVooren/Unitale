using UnityEngine;
using UnityEditor;
using System.Collections;

namespace SpriteLayout
{
    [CustomEditor(typeof(SpriteLayoutRoot))]
    [CanEditMultipleObjects]
    public class SpriteLayoutRootInspector : Editor
    {
        public override void OnInspectorGUI()
        {
            //base.OnInspectorGUI();
            //SpriteLayoutRoot[] roots = (SpriteLayoutRoot[])targets;

            for (int i = 0; i < targets.Length; i++)
            {
                if (GUILayout.Button("Reset parent"))
                {
                    var slb = ((SpriteLayoutBase)targets[i]);
                    slb.Initialize();
                }

                SpriteLayoutRoot root = (SpriteLayoutRoot) targets[i];
                //spr.Width =  EditorGUILayout.FloatField("Width", spr.Width);
                root.PixelsPerUnit = EditorGUILayout.IntField("Pixels per Unit", root.PixelsPerUnit);
            }

        }
    }

	[RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
	public class SpriteLayoutRoot : SpriteLayoutBase
	{
		public Camera SpriteCamera;

        [Range(1,Mathf.Infinity)]
		public int PixelsPerUnit = 1;

		#if UNITY_EDITOR
			const float timeBetweenUpdates = 0.1f;
		#elif UNITY_IOS || UNITY_ANDROID || UNITY_WINRT //tablet devices
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
