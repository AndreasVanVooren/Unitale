using UnityEngine;
using UnityEditor;
using System.Collections;

public enum ColliderType
{
	Rect,
	Circle,
}

[CustomEditor(typeof(Transform))]
public class TransformSpriteLayout : Editor
{
	public override void OnInspectorGUI()
	{
		if (((Transform)target).GetComponentInParent<SpriteLayout>() != null)
		{
			EditorGUILayout.HelpBox("Controlled by SpriteLayout\n(Although you can tweak it in the debug inspector)",MessageType.Warning);
			return;
		}
		base.OnInspectorGUI();
	}
}

[CustomEditor(typeof(SpriteLayout))]
public class CustSpriteRendInspector : Editor
{
	public override void OnInspectorGUI()
	{
		base.OnInspectorGUI ();

		var tgt = (SpriteLayout)target;

		if (tgt.transform.parent == null || tgt.transform.GetComponentInParent<SpriteLayout>() == null) 
		{
			EditorGUILayout.LabelField("Needs parent sprite for anchoring");
		} 
		else 
		{
			tgt.Anchor = EditorGUILayout.Vector2Field ("Anchor", tgt.Anchor);
		}
		tgt.Pivot = EditorGUILayout.Vector2Field ("Pivot", tgt.Pivot);
	}
}

[RequireComponent(typeof(SpriteRenderer))]
[ExecuteInEditMode]
public class SpriteLayout : MonoBehaviour
{
	private SpriteLayout _parent;

	private Vector3 _localPosition;

	private SpriteRenderer _renderer;
	private Sprite _mySprite;

	/// <summary>
	/// The anchor, aka where this sprite attaches to on its parent
	/// </summary>
	private Vector2 _anchor = new Vector2(0.5f,0.5f);
	public Vector2 Anchor
	{
		get { return _anchor; }
		set 
		{ 
			if (_anchor == value)
				return;
			var pSprite = GetComponentInParent<SpriteLayout>();
			if (pSprite == null)
			{
				//Debug.Log("parent null");
				return;
			}

			Vector3 anch = _anchor;
			anch.x -= 0.5f;
			anch.y -= 0.5f;
			anch.Scale( pSprite._mySprite.bounds.extents );

			Vector3 diff = transform.localPosition - anch ;
			//Debug.Log(diff);
			_anchor = value; 

			anch = value;
			anch.x -= 0.5f;
			anch.y -= 0.5f;
			anch.Scale( pSprite._mySprite.bounds.extents );

			transform.localPosition = diff + anch;
		}
	}

	/// <summary>
	/// The pivot.
	/// </summary>
	private Vector2 _pivot = new Vector2(0.5f,0.5f);
	public Vector2 Pivot
	{
		get { return _pivot; }
		set 
		{ 
			//_mySprite.pivot = value;
			_pivot = value; 
		}
	}
	// Use this for initialization
	void Awake ()
	{
		_renderer = GetComponent<SpriteRenderer> ();
		_mySprite = _renderer.sprite;
		_parent = GetComponentInParent<SpriteLayout>();
		//transform.
	}

	public void AttachCollider(ColliderType type)
	{
		switch (type) 
		{
			case ColliderType.Rect:
				{
					var collider = this.gameObject.AddComponent<BoxCollider2D>();
					collider.size = _mySprite.bounds.size;
					break;
				}
			case ColliderType.Circle:
				{
					var collider = this.gameObject.AddComponent<CircleCollider2D>();
					float avg = (_mySprite.bounds.size.x + _mySprite.bounds.size.y) / 2;
					collider.radius = avg;
					break;
				}
			default:
				break;
		}
	}

	// Update is called once per frame
	void Update ()
	{
		//transform.localPosition = _localPosition;
	}

	public void MoveTo(Vector2 vec)
	{
		if (_parent == null)
		{
			transform.localPosition = (Vector3)vec;
			return;
		}

		Vector3 anch = _anchor;
		anch.x -= 0.5f;
		anch.y -= 0.5f;
		anch.Scale( _parent._mySprite.bounds.extents );

		transform.localPosition = anch + (Vector3)vec;
	}
}
