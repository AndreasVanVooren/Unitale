using UnityEngine;
using UnityEditor;
using System.Collections;

namespace SpriteLayout
{
	[CustomEditor(typeof(Transform))]
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

			var t = (Transform)target;
			if(t && t.GetComponent<SpriteLayoutBase>() == null)
			{
				DrawDefaultInspector();
			}
            //var arr = (Transform[])targets;

            //for (int i = 0; i < targets.Length; i++)
           //{
           //    var t = (Transform) target;
			//	if (t == null)
			//		//continue;
			//		return;
           //    var spr = t.GetComponent<SpriteLayoutBase>();
		   //
           //    if (spr != null)
           //    {
           //        EditorGUILayout.HelpBox("These are SpriteLayout controls,\nfor actual transform controls, check the debug inspector", MessageType.Warning);
		   //
           //        spr.LocalPosition = EditorGUILayout.Vector3Field("Position", spr.LocalPosition);
           //        spr.LocalRotation = Quaternion.Euler(EditorGUILayout.Vector3Field("Rotation", spr.LocalRotation.eulerAngles));
           //        spr.LocalScale = EditorGUILayout.Vector3Field("Scale", spr.LocalScale);
		   //
           //        spr.Width =  EditorGUILayout.FloatField("Width", spr.Width);
           //        spr.Height = EditorGUILayout.FloatField("Height", spr.Height);
		   //
           //        var parents = spr. GetComponentsInParent<SpriteLayoutBase>();
		   //
           //        spr.Anchor = EditorGUILayout.Vector2Field("Anchor", spr.Anchor);
           //        
           //        if(spr.Parent == null || t.parent == null || parents.Length <= 1)
           //        {
           //            EditorGUILayout.LabelField("Needs parent for anchoring to have effect");
           //        }
		   //
           //        spr.Pivot = EditorGUILayout.Vector2Field("Pivot", spr.Pivot);
		   //
           //        if (GUI.changed)
           //        {
			//			//Debug.Log("fsadfsafd");
           //            EditorUtility.SetDirty(spr.gameObject);
           //        }
		   //
           //        //continue;
           //    }
		   //
           //    serializedObject.Update();
		   //
           //    //EditorGUILayout.PropertyField(locPos,new GUIContent("Position"));
           //    //EditorGUILayout.PropertyField(locRot, new GUIContent("Rotation"));
           //    //EditorGUILayout.PropertyField(locScale, new GUIContent("Scale"));
		   //
           //    t.localPosition = EditorGUILayout.Vector3Field("Position", t.localPosition);
           //    t.localRotation = Quaternion.Euler(EditorGUILayout.Vector3Field("Rotation", t.localRotation.eulerAngles));
           //    t.localScale = EditorGUILayout.Vector3Field("Scale", t.localScale);
           //    //DrawDefaultInspector();
		   //
           //    //serializedObject.ApplyModifiedProperties();
           //    if(GUI.changed)
           //    {
           //        EditorUtility.SetDirty( t );
           //    }
           //}

			
		}
	}

	//[CustomEditor(typeof(SpriteLayoutBase))]
	//public class SpriteLayoutBaseInspector : Editor
	//{
	//	public override void OnInspectorGUI()
	//	{
	//		//base.OnInspectorGUI();
	//		//
	//		//var tgt = (SpriteLayoutBase)target;
	//		//
	//		//if (tgt.transform.parent == null || tgt.transform.GetComponentInParent<SpriteLayoutBase>() == null)
	//		//{
	//		//	EditorGUILayout.LabelField("Needs parent sprite for anchoring");
	//		//}
	//		//else
	//		//{
	//		//	tgt.Anchor = EditorGUILayout.Vector2Field("Anchor", tgt.Anchor);
	//		//}
	//		//tgt.Pivot = EditorGUILayout.Vector2Field("Pivot", tgt.Pivot);
    //        if (GUILayout.Button("Reset parent"))
    //        {
    //            var slb = ((SpriteLayoutBase)target);
    //            slb.Initialize();
    //        }
	//
    //        if(GUILayout.Button("Make Image"))
	//		{
    //            var slb = ((SpriteLayoutBase)target);
	//			var img = slb.gameObject.AddComponent<SpriteLayoutImage>();
	//			img.InitFromOther(slb);
    //            Destroy(slb);
	//		}
	//
	//	}
	//}

    public class SpriteLayoutBase : MonoBehaviour
	{
		public bool DebugMe = false;
		[SerializeField] private Vector3 _localPosition = Vector3.zero;
		public Vector3 LocalPosition
		{
			get { return _localPosition; }
			set
			{
				_localPosition = value;
				ResetTransform();
			}
		}

        public Vector3 Position
        {
            get 
            { 
                if (transform == null || transform.parent == null || Parent == null)
                {
                    return LocalPosition;
                }

                Vector3 parentPos = Parent.Center ;
				Vector2 anch = this.AnchorVector;
				//anch.Scale(Parent.DimensionRatioInverse);
				//anch.Scale(Parent.Scale);
				Vector3 posDiff = (Vector3)anch + LocalPosition;
				//posDiff.Scale(Parent.DimensionRatioInverse);
				posDiff.Scale(Parent.Scale);
				parentPos += Parent.Rotation * posDiff;
                return parentPos ; 
            }
            set
            {
                var diff = value - Position;
				//Take into account that LocalPosition set already resets position
				if(DebugMe && Input.GetKey(KeyCode.Minus))
				{
					Debug.LogFormat(gameObject, "[{0}] - val:{1} orig:{2} diff:{3}", gameObject.name, value, Position, diff);
				}

				if (Parent)
				{
					//first rotate, then scale
					diff = Quaternion.Inverse(Parent.Rotation) * diff;
					var parentScale = Parent.Scale;
					diff.x /= parentScale.x;
					diff.y /= parentScale.y;
					//diff.z /= parentScale.z;
				}
                LocalPosition += diff;
            }
        }

        //Position and local position properties offset the actual transform using pivots and stuff.
        //This just requests the true center.
        public Vector3 Center
        {
            get
            {
                return transform.position;
            }
        }

        [SerializeField] private Quaternion _localRotation = Quaternion.identity;
		public Quaternion LocalRotation
		{
			get { return _localRotation; }
			set
			{
				_localRotation = value;
				ResetTransform();
				//ResetRotation ();
				//ResetPosition ();
			}
		}

        public Vector3 LocalEulerAngles
        {
            get { return LocalRotation.eulerAngles; }
            set 
			{ 
				LocalRotation = Quaternion.Euler( value ); 
			}
        }

        public Quaternion Rotation
        {
            get { return transform.rotation; }
            set 
            { 
                var diff = value * Quaternion.Inverse(Rotation);
                LocalRotation *= diff;
            }
        }

        public Vector3 EulerAngles
        {
            get
            {
                if (transform == null || transform.parent == null)
                {
                    return LocalEulerAngles;
                }
                return transform.parent.eulerAngles + LocalEulerAngles;
            }
            set
            {
                var diff = value - EulerAngles;
                LocalEulerAngles += diff;
            }
        }

        [SerializeField] private Vector3 _localScale = Vector3.one;
		public Vector3 LocalScale
		{
			get { return _localScale; }
			set
			{
				_localScale = value;
                ResetTransform ();
				//ResetPosition ();
			}
		}

        public Vector3 Scale
        {
            get
            {
                Vector3 scale = Vector3.one;

				var pSprite = Parent;
				if (pSprite == null)
                {
                    var parents = GetComponentsInParent<SpriteLayoutBase>();
                    if (parents.Length > 1)
						pSprite = Parent = parents[1];
                }

				if(pSprite != null)
				{
					scale = Parent.Scale;
					scale.Scale(this.LocalScale);
				}
				else
				{
					scale = this.LocalScale;
				}

				if (scale.z == 0)
				{
					scale.z = 1;
				}
				return scale;

            }
            set
            {
                SpriteLayoutBase p = Parent;
                if (p == null)
                {
                    var parents = GetComponentsInParent<SpriteLayoutBase>();
                    if (parents.Length > 1)
                        p = parents[1];
                }
                var parentScale = p.Scale;
                var scale = value;
                scale.x *= 1 / parentScale.x;
                scale.y *= 1 / parentScale.y;
                scale.z *= 1 / parentScale.z;
				
                LocalScale = scale;
            }
        }

		//private SpriteRenderer _renderer;
		//private Sprite _mySprite;

        [SerializeField] protected Vector2 _initialDimensions = Vector2.one;
		[SerializeField] private Vector2 _dimensions = Vector2.one;
		public Vector2 Dimensions
		{
			get { return _dimensions; }
			set
			{
				_dimensions = value;
				//#if UNITY_EDITOR
				//if(!EditorApplication.isPlaying)
				//{
				//	_initialDimensions = value;
				//}
				//#endif
                ResetTransform ();
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
				Dimensions = new Vector2(value, _dimensions.y); 
				//ResetScale ();
				//ResetPosition ();
			}
		}

		public float Height
		{
			get { return Dimensions.y; }
			set 
			{
				Dimensions = new Vector2(_dimensions.x, value); 
				//ResetScale ();
				//ResetPosition ();
			}
		}

		public Vector2 DimensionRatio
		{
			get
			{
				Vector2 vec = new Vector2();
				vec.x = Width / _initialDimensions.x;
				vec.y = Height / _initialDimensions.y;
				return vec; 
			}
		}

		public Vector2 DimensionRatioInverse
		{
			get
			{
				Vector2 vec = new Vector2();
				vec.x = _initialDimensions.x / Width;
				vec.y = _initialDimensions.y / Height;
				return vec; 
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
				//var pSprite = Parent;
				//if (pSprite == null)
				//{
				//	//Debug.Log("parent null");
				//	var parents = GetComponentsInParent<SpriteLayoutBase>();
				//	if (parents.Length > 1)
				//		pSprite = parents[1];
				//	else return;
				//}
				_anchor = value;
				//ResetPosition ();
			}
		}

		public Vector2 AnchorVector
		{
			get
			{
				var pSprite = Parent;
				if(pSprite == null)
				{
					var parents = GetComponentsInParent<SpriteLayoutBase>();
					if (parents.Length > 1)
						pSprite = Parent =  parents[1];
					else return Vector2.zero;
				}

				Vector2 anch = _anchor;

				anch.x -= 0.5f;
				anch.y -= 0.5f;
				anch.Scale(pSprite.Dimensions);
				//anch.Scale (pSprite.LocalScale);
				//anch.Scale (pSprite.DimensionRatioInverse);
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
				_pivot = value;
				//ResetPosition ();
			}
		}

		public Vector2 PivotVector
		{
			get
			{
				//if (_mySprite != null)
				{
					Vector2 piv = _pivot;

					piv.x -= 0.5f;
					piv.y -= 0.5f;
					piv.Scale(Dimensions);
                    //piv.Scale(LocalScale);
					return piv;
				}
				//return Vector2.zero;

			}
		}
        [SerializeField, HideInInspector]
		public SpriteLayoutBase Parent
		{ get; protected set; }

		public void InitFromOther(SpriteLayoutBase b)
		{
			this._anchor = b._anchor;
			this._dimensions = b._dimensions;
			this._initialDimensions = b._initialDimensions;
			this._localPosition = b._localPosition;
			this._localRotation = b._localRotation;
			this._localScale = b._localScale;
			this._pivot = b._pivot;
			this.Parent = b.Parent;
			this.ResetScale();
			this.ResetRotation();
			this.ResetPosition();
		}

		internal virtual void Initialize()
		{
//			if(transform.parent == null)
//			{
//				Debug.Log("NO PARENTS!");
//			}
            _initialDimensions = Dimensions;

			var parents = GetComponentsInParent<SpriteLayoutBase>();
			if (parents.Length > 1)	//check if there is a gameobject.
				Parent = parents[1];
			if (Parent == this) Parent = null;

			ResetTransform();
		}

		protected void ResetTransform()
		{
			ResetTransform(true);
		}

        protected virtual void ResetTransform(bool recursive )
        {
            ResetScale();
            ResetRotation();
            ResetPosition();

			if(DebugMe)
			{
				Debug.LogFormat("Pos : {0}, LocalPos : {1}", Position, LocalPosition);
			}

			if (!recursive) return;
			for (int i = 0; i < transform.childCount; i++)
			{
				var myChild = transform.GetChild(i).GetComponent<SpriteLayoutBase>();
				//toriel wuz here
				if(myChild)
				{
					myChild.ResetTransform();
				}
			}
        }

		protected void ResetScale()
		{
			//Vector3 newScale = new Vector3();
			//
            //newScale.x = DimensionRatio.x * LocalScale.x;
            //newScale.y = DimensionRatio.y * LocalScale.y;
            //newScale.z = LocalScale.z;
			//
            //var pSprite = Parent;
            //if(pSprite == null)
            //{
            //    var parents = GetComponentsInParent<SpriteLayoutBase>();
            //    if (parents.Length > 1)
            //    {
            //        pSprite = Parent = parents[1];
            //    }
            //}
            //
            //
            //if (pSprite != null)
			//{
			//	newScale.Scale(pSprite.DimensionRatioInverse);
            //}

            

            //if (pSprite != null)
            //{
            //    Vector3 counterScale = pSprite.transform.localScale;
            //    counterScale.x = 1 / counterScale.x;
            //    counterScale.y = 1 / counterScale.y;
            //    counterScale.z = 1 / counterScale.z;
            //    newScale.Scale(counterScale);
            //}

			transform.localScale = LocalScale;
		}

		protected void ResetRotation()
		{
			transform.localRotation = LocalRotation;
		}

		protected void ResetPosition()
		{
            Vector3 newPos = LocalPosition + (Vector3)AnchorVector;
            Vector3 piv = PivotVector;
			piv.Scale(LocalScale);
			piv = LocalRotation * piv;
            newPos -= piv;

            //counter act unity scaling due to 
            //if (Parent != null)
            //{
            //    newPos.Scale(Parent.DimensionRatioInverse);
            //}
            transform.localPosition = newPos;
		}

		// Use this for initialization
		void Awake()
		{
			Initialize();
		}

		//void Start()
		//{
		//	ResetTransform();
		//}

		// Update is called once per frame
		void Update()
		{

		}

        public void ResetDimensions(Vector2 newDimensions)
        {
            _initialDimensions = newDimensions;
            Dimensions = newDimensions;
        }
        public void ResetDimensions()
        {
            Dimensions = _initialDimensions;
        }

        public void SetParent(Transform parent)
        {
            transform.SetParent( parent );

			if (parent == null)
			{
				LocalScale = Scale;
				LocalRotation = Rotation;
				LocalPosition = Position;
				this.Parent = null;
				ResetTransform();
				return;
			}

            var pSprite = parent.GetComponent<SpriteLayoutBase>();
            if (pSprite != null)
            {
				var scale = Scale;
				var rotation = Rotation;
				var position = Position;
				this.Parent = pSprite;
				Scale = scale;
				Rotation = rotation;
				Position = position;
            }
            else
			{
				LocalScale = Scale;
				LocalRotation = Rotation;
				LocalPosition = Position;
				this.Parent = null;
            }
			ResetTransform();
        }
	}
}
