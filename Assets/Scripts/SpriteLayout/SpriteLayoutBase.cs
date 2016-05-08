using UnityEngine;
using UnityEditor;
using System.Collections;

namespace SpriteLayout
{
	[CustomEditor(typeof(Transform))]
    [CanEditMultipleObjects]
	public class SpriteLayoutTransformInspector : Editor
	{
		//SerializedProperty locPos;
		//SerializedProperty locRot;
		//SerializedProperty locScale;

		void OnEnable()
		{
			//locPos = serializedObject.FindProperty("localPosition");
			//locRot = serializedObject.FindProperty("localRotation");
			//locScale = serializedObject.FindProperty("localScale");
		}

		public override void OnInspectorGUI()
		{
            //var arr = (Transform[])targets;

            for (int i = 0; i < targets.Length; i++)
            {
                var t = (Transform) targets[i];
                if (t == null)
                    continue;

                var spr = t.GetComponent<SpriteLayoutBase>();

                if (spr != null)
                {
                    EditorGUILayout.HelpBox("These are SpriteLayout controls,\nfor actual transform controls, check the debug inspector", MessageType.Warning);

                    spr.LocalPosition = EditorGUILayout.Vector3Field("Position", spr.LocalPosition);
                    spr.LocalRotation = Quaternion.Euler(EditorGUILayout.Vector3Field("Rotation", spr.LocalRotation.eulerAngles));
                    spr.LocalScale = EditorGUILayout.Vector3Field("Scale", spr.LocalScale);

                    spr.Width =  EditorGUILayout.FloatField("Width", spr.Width);
                    spr.Height = EditorGUILayout.FloatField("Height", spr.Height);

                    var parents = spr. GetComponentsInParent<SpriteLayoutBase>();

                    if(spr.Parent == null || t.parent == null || parents.Length <= 1)
                    {
                        if(t.GetComponentInParent<SpriteLayoutBase>() == spr)
                        {
                            Debug.Log(t.GetComponentInParent<SpriteLayoutBase>().GetInstanceID());
                            Debug.Log(spr.GetInstanceID());
                        }
                        EditorGUILayout.LabelField("Needs parent for anchoring");
                    }
                    else
                    {
                        spr.Anchor = EditorGUILayout.Vector2Field("Anchor", spr.Anchor);
                    }
                    spr.Pivot = EditorGUILayout.Vector2Field("Pivot", spr.Pivot);

                    if (GUI.changed)
                    {
                        EditorUtility.SetDirty(spr);
                    }

                    continue;
                }

                serializedObject.Update();

                //EditorGUILayout.PropertyField(locPos,new GUIContent("Position"));
                //EditorGUILayout.PropertyField(locRot, new GUIContent("Rotation"));
                //EditorGUILayout.PropertyField(locScale, new GUIContent("Scale"));

                t.localPosition = EditorGUILayout.Vector3Field("Position", t.localPosition);
                t.localRotation = Quaternion.Euler(EditorGUILayout.Vector3Field("Rotation", t.localRotation.eulerAngles));
                t.localScale = EditorGUILayout.Vector3Field("Scale", t.localScale);
                //DrawDefaultInspector();

                //serializedObject.ApplyModifiedProperties();
                if(GUI.changed)
                {
                    EditorUtility.SetDirty( t );
                }
            }

			
		}
	}

	[CustomEditor(typeof(SpriteLayoutBase))]
	public class SpriteLayoutBaseInspector : Editor
	{
		public override void OnInspectorGUI()
		{
			//base.OnInspectorGUI();
			//
			//var tgt = (SpriteLayoutBase)target;
			//
			//if (tgt.transform.parent == null || tgt.transform.GetComponentInParent<SpriteLayoutBase>() == null)
			//{
			//	EditorGUILayout.LabelField("Needs parent sprite for anchoring");
			//}
			//else
			//{
			//	tgt.Anchor = EditorGUILayout.Vector2Field("Anchor", tgt.Anchor);
			//}
			//tgt.Pivot = EditorGUILayout.Vector2Field("Pivot", tgt.Pivot);
		}
	}

	[ExecuteInEditMode]
	public class SpriteLayoutBase : MonoBehaviour
	{
		//protected delegate void OnPropertyChangeLocPos();
		//protected delegate void OnPropertyChangeLocRot();
		//protected delegate void OnPropertyChangeLocScale();
		//protected delegate void OnPropertyChangeWidth();
		//protected delegate void OnPropertyChangeHeight();
		//protected delegate void OnPropertyChangeAnch();
		//protected delegate void OnPropertyChangePiv();

		[SerializeField] private Vector3 _localPosition;
		public Vector3 LocalPosition
		{
			get { return _localPosition; }
			set
			{

				_localPosition = value;

				transform.localPosition = value + (Vector3)NormalizedAnchor;
			}
		}

        public Vector3 Position
        {
            get { return transform.parent.position + _localPosition; }
            set
            {
                var diff = value - Position;
                _localPosition += diff;
            }
        }

		[SerializeField] private Quaternion _localRotation;
		public Quaternion LocalRotation
		{
			get { return _localRotation; }
			set
			{
				_localRotation = value;

				Vector2 dir = _localRotation * NormalizedPivot;

				transform.localPosition = (Vector3)(NormalizedAnchor - dir) + LocalPosition;
			}
		}

        public Vector3 LocalEulerAngles
        {
            get { return LocalRotation.eulerAngles; }
            set { LocalRotation = Quaternion.Euler( value ); }
        }

        public Quaternion Rotation
        {
            get { return transform.parent.rotation * LocalRotation; }
            set 
            { 
                var diff = value * Quaternion.Inverse(Rotation);
                LocalRotation *= diff;
            }
        }

        public Vector3 EulerAngles
        {
            get{return transform.parent.eulerAngles + LocalEulerAngles;}
            set
            {
                var diff = value - EulerAngles;
                LocalEulerAngles += diff;
            }
        }

		[SerializeField] private Vector3 _localScale = new Vector3(1.0f, 1.0f, 1.0f);
		public Vector3 LocalScale
		{
			get { return _localScale; }
			set
			{
				_localScale = value;

				//transform.localPosition = 
			}
		}

		//private SpriteRenderer _renderer;
		//private Sprite _mySprite;

		[SerializeField] protected Vector2 _initialDimensions = new Vector2(1, 1);
		[SerializeField] private Vector2 _dimensions = new Vector2(1, 1);
		public Vector2 Dimensions
		{
			get { return _dimensions; }
			set
			{
				_dimensions = value;
			}
		}

		public Vector2 Extents
		{
			get { return Dimensions / 2; }
		}

		public float Width
		{
			get { return Dimensions.x; }
			set 
			{ 
				var scale = transform.localScale;
				scale.x = value / _initialDimensions.x;
				transform.localScale = scale;
				Dimensions = new Vector2(value, _dimensions.y);
			}
		}

		public float Height
		{
			get { return Dimensions.y; }
			set 
			{
				var scale = transform.localScale;
				scale.y *= value / _initialDimensions.y;
				transform.localScale = scale;
				Dimensions = new Vector2(_dimensions.x, value); 
			}
		}

		/// <summary>
		/// The anchor, aka where this sprite attaches to on its parent
		/// </summary>
		[SerializeField] private Vector2 _anchor = new Vector2(0.5f, 0.5f);
		public Vector2 Anchor
		{
			get { return _anchor; }
			set
			{
				if (_anchor == value)
					return;
				var pSprite = GetComponentInParent<SpriteLayoutImage>();
				if (pSprite == null)
				{
					//Debug.Log("parent null");
					return;
				}

				Vector3 anch = NormalizedAnchor;

				Vector3 diff = transform.localPosition - anch;
				//Debug.Log(diff);
				_anchor = value;

				anch = NormalizedAnchor;

				transform.localPosition = diff + anch;
			}
		}

		public Vector2 NormalizedAnchor
		{
			get
			{
				var pSprite = Parent;
				if(pSprite == null)
				{
					var parents = GetComponentsInParent<SpriteLayoutBase>();
					if (parents.Length > 1)
						pSprite = parents[1];
					else return Vector2.zero;
				}

				Vector2 anch = _anchor;

				anch.x -= 0.5f;
				anch.y -= 0.5f;
				anch.Scale(pSprite.Dimensions);
				return anch;

			}
		}

		/// <summary>
		/// The pivot.
		/// </summary>
		[SerializeField] private Vector2 _pivot = new Vector2(0.5f, 0.5f);
		public Vector2 Pivot
		{
			get { return _pivot; }
			set
			{
				//_mySprite.pivot = value;
				//if (_mySprite != null)
				{
					Vector2 diff = value - _pivot;
					//diff.x -= 0.5f;
					//diff.y -= 0.5f;
					diff.Scale(Dimensions);
					diff.Scale(LocalScale);
					diff = LocalRotation * diff;

					Vector3 pos = transform.localPosition + (Vector3)diff;
					transform.localPosition = pos;
				}

				_pivot = value;
			}
		}

		public Vector2 NormalizedPivot
		{
			get
			{
				//if (_mySprite != null)
				{
					Vector2 piv = _pivot;

					piv.x -= 0.5f;
					piv.y -= 0.5f;
					piv.Scale(Dimensions);
					return piv;
				}
				//return Vector2.zero;

			}
		}
		[SerializeField]
		public SpriteLayoutBase Parent
		{ get; protected set; }


		protected virtual void Initialize()
		{
			if(transform.parent == null)
			{
				Debug.Log("NO PARENTS!");
			}
			var parents = GetComponentsInParent<SpriteLayoutBase>();
			if (parents.Length > 1)	//check if there is a gameobject.
				Parent = parents[1];
			if (Parent == this) Parent = null;
		}

		// Use this for initialization
		void Awake()
		{
			Initialize();
		}

		// Update is called once per frame
		void Update()
		{

		}

        public void ResetDimensions(Vector2 newDimensions)
        {
            _initialDimensions = newDimensions;
            Dimensions = newDimensions;
        }

        public void SetParent(Transform parent)
        {
            transform.SetParent( parent );

            if (parent == null)
                return;

            var pSprite = parent.GetComponent<SpriteLayoutBase>();
            if (pSprite != null)
            {
                this.Parent = pSprite;              
            }
            else
            {
                this.Parent = null;
            }
        }
	}
}