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



	[CustomEditor(typeof(SpriteLayoutImage))]
	public class SpriteLayoutImageInspector : Editor
	{
		public override void OnInspectorGUI()
		{
			//base.OnInspectorGUI();
            if (GUILayout.Button("Reset parent"))
            {
                var slb = ((SpriteLayoutBase)target);
                slb.Initialize();
            }
		}
	}

	[RequireComponent(typeof(SpriteRenderer))]
	public class SpriteLayoutImage : SpriteLayoutBase
	{
        private const string _nullPath = "WhiteSquare";
        private static Sprite _null;

        private SpriteRenderer _renderer;
        private Sprite _mySprite;

        public Sprite Sprite
        {
            get { return _mySprite; }
            set 
            { 
                _renderer.sprite = value; 
                _mySprite = value;
                if (value != null)
                {
                    _initialDimensions = _mySprite.bounds.size;
                }
                else
                {
                    _renderer.sprite = _null;
                    _initialDimensions = new Vector2(1, 1);
                }
                ResetTransform();
            }
        }

        public Color Color
        {
            get { return _renderer.color; }
            set { _renderer.color = value; }
        }

        //TODO : Do this differently?
        private static int _lowestOrder = 0;
        private static int _highestOrder = 0;
        public int SortingOrder
        {
            get { return _renderer.sortingOrder; }
            set 
            { 
                _renderer.sortingOrder = value; 
                if (value > _highestOrder)
                    _highestOrder = value;
                if (value < _lowestOrder)
                    _lowestOrder = value;
            }
        }

        public string SortingLayerName
        {
            get { return _renderer.sortingLayerName; }
            set
            {
                _renderer.sortingLayerName = value;
            }
        }

        public int SortingLayerID
        {
            get { return _renderer.sortingLayerID; }
            set
            {
                _renderer.sortingLayerID = value;
            }
        }

        public bool RendererEnabled
        {
            get { return _renderer.enabled; }
            set { _renderer.enabled = value; }
        }

        internal override void Initialize()
		{
			base.Initialize();

            if (!_null)
            {
                _null = Resources.Load<Sprite>(_nullPath);
            }

			_renderer =GetComponent<SpriteRenderer>();
            Sprite = _renderer.sprite;

			//_mySprite = _renderer.sprite;
            //if (_mySprite != null)
            //    _initialDimensions = _mySprite.bounds.size;
            //else
            //{
            //   _renderer.sprite = _null;
            //   _initialDimensions = new Vector2(1, 1);
            //}
            ++_highestOrder;
            _renderer.sortingOrder = _highestOrder;
		}

		// Use this for initialization
		void Awake()
		{
			Initialize();
			//transform.
		}


        public void AttachCollider(ColliderType type)
		{
			switch (type)
			{
				case ColliderType.Rect:
					{
						var collider = this.gameObject.AddComponent<BoxCollider2D>();
						collider.size = Dimensions;
						break;
					}
				case ColliderType.Circle:
					{
						var collider = this.gameObject.AddComponent<CircleCollider2D>();
						float avg = (Dimensions.x + Dimensions.y) / 2;
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

		// Update is called once per frame
		void Update()
		{
			//transform.localPosition = _localPosition;
		}
	}
}