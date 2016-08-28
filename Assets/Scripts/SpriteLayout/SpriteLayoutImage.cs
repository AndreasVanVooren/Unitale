using UnityEngine;
using UnityEditor;
using System.Collections;

namespace SpriteLayout
{
	public enum ColliderType
	{
		Rect,
		Circle,
	}



	//[CustomEditor(typeof(SpriteLayoutImage))]
	//public class SpriteLayoutImageInspector : Editor
	//{
	//	public override void OnInspectorGUI()
	//	{
	//		//base.OnInspectorGUI();
    //        if (GUILayout.Button("Reset parent"))
    //        {
    //            var slb = ((SpriteLayoutBase)target);
    //            slb.Initialize();
    //        }
	//	}
	//}

	//[RequireComponent(typeof(SpriteRenderer))]
	public class SpriteLayoutImage : SpriteLayoutBase
	{
        private const string _nullPath = "WhiteSquare";
        private static Sprite _null;

        public SpriteRenderer Renderer
		{
			get; private set;
		}
		
        private Sprite _mySprite;
		private Sprite _override;

		public Sprite InitialSprite;

		public Sprite Sprite
        {
            get { return _mySprite; }
            set 
            { 
				if(Renderer && _override == null)
					Renderer.sprite = value; 
                _mySprite = value;
                if (value != null)
                {
                    _initialDimensions = _mySprite.bounds.size;
                }
                else
                {
                    Renderer.sprite = _null;
                    _initialDimensions = _null.bounds.size;
                }
                //ResetTransform();
            }
        }

		public Sprite OverrideSprite
		{
			get { return _override; }
			set 
			{
				if(Renderer)
				{
					_override = value;
					if (_override != null)
					{
						Renderer.sprite = _override;
						_initialDimensions = _override.bounds.size;
					}
					else
					{
						Renderer.sprite = _mySprite;
						_initialDimensions = _mySprite.bounds.size;
					}
				}
			}
		}
		public Color InitialColor = Color.white;

        public Color Color
        {
            get 
			{
				if (!Renderer) return Color.black;
				return Renderer.color; 
			}
            set 
			{ 
				if(Renderer)
					Renderer.color = value; 
			}
        }

		public void SendToTop()
		{
			if(SortingOrder < _highestOrder)
				SortingOrder = _highestOrder + 1;
		}

		public void SendToBottom()
		{
			if(SortingOrder > _lowestOrder)
				SortingOrder = _lowestOrder - 1;
		}

        //TODO : Do this differently?
        private static int _lowestOrder = 0;
        private static int _highestOrder = 0;
        public int SortingOrder
        {
            get 
			{
				if (!Renderer) return 0;
				return Renderer.sortingOrder; 
			}
            set 
            {
				if (!Renderer) return;
				Renderer.sortingOrder = value; 
                if (value > _highestOrder)
                    _highestOrder = value;
                if (value < _lowestOrder)
                    _lowestOrder = value;
            }
        }

		public string InitialSortingLayerName;
        public string SortingLayerName
        {
            get 
			{
				if (!Renderer) return "";
				return Renderer.sortingLayerName; 
			}
            set
            {
				if (!Renderer) return;
				Renderer.sortingLayerName = value;
            }
        }

        public int SortingLayerID
        {
            get 
			{
				if (!Renderer) return -1;
				return Renderer.sortingLayerID; 
			}
            set
            {
				if (!Renderer) return;
				Renderer.sortingLayerID = value;
            }
        }

		public bool EnabledOnPlay = true;
        public bool RendererEnabled
        {
            get 
			{
				if (!Renderer) return false;
				return Renderer.enabled; 
			}
            set 
			{ 
				if(Renderer)
					Renderer.enabled = value; 
			}
        }

        internal override void Initialize()
		{
			base.Initialize();

            if (!_null)
            {
                _null = Resources.Load<Sprite>(_nullPath);
            }

			//create sub-object with sprite renderer
			var go = new GameObject(string.Format("Img of {0}", gameObject.name));
			go.transform.parent = this.transform;
			go.transform.localPosition = Vector3.zero;
			go.transform.localRotation = Quaternion.identity;
			Vector3 scale = DimensionRatio;
			scale.z = 1;
			go.transform.localScale = scale;

			var initialRenderer = GetComponent<SpriteRenderer>();

			Renderer = go.AddComponent<SpriteRenderer>();
			
			if(initialRenderer)
			{
				Sprite = initialRenderer.sprite;
				Renderer.sortingLayerID = initialRenderer.sortingLayerID;
				Renderer.color = initialRenderer.color;
				Renderer.enabled = initialRenderer.enabled;

				Destroy(initialRenderer);
			}
			else
			{
				Sprite = InitialSprite;
				Renderer.sortingLayerName = InitialSortingLayerName;
				Renderer.color = InitialColor;
				Renderer.enabled = EnabledOnPlay;
			}
			
			//_mySprite = _renderer.sprite;
            //if (_mySprite != null)
            //    _initialDimensions = _mySprite.bounds.size;
            //else
            //{
            //   _renderer.sprite = _null;
            //   _initialDimensions = new Vector2(1, 1);
            //}
            ++_highestOrder;
            Renderer.sortingOrder = _highestOrder;
		}

		// Use this for initialization
		void Awake()
		{
			Initialize();
			//transform.
		}


        public void AttachCollider(ColliderType type)
		{
			if(this.GetComponent<Rigidbody2D>() == null)
			{
				var body = this.gameObject.AddComponent<Rigidbody2D>();
				body.gravityScale = 0;
				body.isKinematic = true;
			}
			
			switch (type)
			{
				case ColliderType.Rect:
					{
						var collider = this.gameObject.AddComponent<BoxCollider2D>();
						collider.isTrigger = true;
						collider.size = Dimensions;
						break;
					}
				case ColliderType.Circle:
					{
						var collider = this.gameObject.AddComponent<CircleCollider2D>();
						collider.isTrigger = true;
						float avg = (Extents.x + Extents.y) / 2;
						collider.radius = avg;
						break;
					}
				default:
					break;
			}
		}

        public void AttachRectCollider(float xOffset, float yOffset, float xSize, float ySize)
        {
            var collider = this.gameObject.AddComponent<BoxCollider2D>();
            collider.offset = new Vector2(xOffset, yOffset);
            collider.size = new Vector2(xSize,ySize);
        }

		protected override void ResetTransform(bool recursive)
		{
			Vector3 baseScale = DimensionRatio;
			baseScale.z = 1;
			if(Renderer)
				Renderer.transform.localScale = baseScale;
			
			base.ResetTransform(recursive);
		}

		// Update is called once per frame
		void Update()
		{
			//transform.localPosition = _localPosition;
		}
	}
}