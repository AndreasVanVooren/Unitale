using UnityEngine;
using SpriteLayout;
using System.Collections;

[RequireComponent(typeof(SpriteLayoutBase))]
public class fjsdalfjsaldk : MonoBehaviour
{

	// Use this for initialization
	void Start()
	{

	}

	// Update is called once per frame
	void Update()
	{
		if (Input.GetKeyDown(KeyCode.Backslash))
		{
			Debug.Log(GetComponent<SpriteLayoutBase>().Position);
		}
		if(Input.GetKeyDown(KeyCode.Equals))
		{
			var thas = GetComponent<SpriteLayoutBase>();
			if(thas && thas.Parent)
			{
				Debug.Log(thas.Parent.DimensionRatioInverse.x);
			}
		}
	}
}