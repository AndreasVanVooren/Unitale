using UnityEngine;
using System.Collections;

namespace SpriteLayout
{
	public enum ColliderType
	{
		Rect,
		Circle,
	}

	[RequireComponent(typeof(SpriteRenderer))]
	[ExecuteInEditMode]
	public class SpriteLayout : SpriteLayoutBase
	{
		private SpriteRenderer _renderer;
		private Sprite _mySprite;

		protected override void Initialize()
		{
			base.Initialize();
			_renderer =GetComponent<SpriteRenderer>();
			_mySprite = _renderer.sprite;
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

		// Update is called once per frame
		void Update()
		{
			//transform.localPosition = _localPosition;
		}
	}
}