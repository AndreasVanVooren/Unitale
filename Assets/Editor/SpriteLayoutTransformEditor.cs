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
			if (t && t.GetComponent<SpriteLayoutBase>() == null)
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

}

