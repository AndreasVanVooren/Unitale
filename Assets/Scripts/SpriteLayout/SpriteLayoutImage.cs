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
		}
	}

	[RequireComponent(typeof(SpriteRenderer))]
	[ExecuteInEditMode]
	public class SpriteLayoutImage : SpriteLayoutBase
	{
		private SpriteRenderer _renderer;
		private Sprite _mySprite;

        public Sprite Sprite
        {
            get { return _renderer.sprite; }
            set 
            { 
                _renderer.sprite = value; 
                _mySprite = value;
                _initialDimensions = _mySprite.bounds.size;
            }
        }

        public Color Color
        {
            get { return _renderer.color; }
            set { _renderer.color = value; }
        }

        public int SortingOrder
        {
            get { return _renderer.sortingOrder; }
            set { _renderer.sortingOrder = value; }
        }

        public bool RendererEnabled
        {
            get { return _renderer.enabled; }
            set { _renderer.enabled = value; }
        }

		protected override void Initialize()
		{
			base.Initialize();
			_renderer =GetComponent<SpriteRenderer>();
			_mySprite = _renderer.sprite;
            if(_mySprite != null)
			    _initialDimensions = Dimensions = _mySprite.bounds.size;
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