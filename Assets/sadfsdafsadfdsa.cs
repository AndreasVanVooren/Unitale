using UnityEngine;
using System.Collections;

public class sadfsdafsadfdsa : MonoBehaviour
{

	// Use this for initialization
	void Start()
	{

	}

	// Update is called once per frame
	void Update()
	{
		if (Input.GetKeyDown(KeyCode.Space))
		{
			this.GetComponent<RectTransform>().pivot = new Vector2(0, 0);
		}
	}
}
