using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CreateRows : MonoBehaviour {
	public bool ifLoadRow = true;
	public GameObject row;
	public Shader rowShader;
	public Text tx;
	public GameObject nR;
	public int num = 1;
	private int now = 0;
	// Use this for initialization
	void Start () {
		tx.text = "0";
	}

	void FixedUpdate () {
		nR.transform.Rotate (new Vector3 (0, 1, 0));
	}

	// Update is called once per frame
	void Update () {
		if (ifLoadRow){
			if (now < num){
				for (int i = 0; i < 1000; ++i) {
					if (now < num) {
						tx.text = "" + now++;
						Material mt = new Material (Shader.Find ("leesue/row"));
						mt.SetVector ("_Color", new Vector4 (Random.Range (0, 1000) / 1000.0f, Random.Range (0, 1000) / 1000.0f, Random.Range (0, 1000) / 1000.0f, 1));
						foreach (Transform child in Instantiate (row, new Vector3 (Random.Range (0, 1000) / 100.0f, Random.Range (0, 1000) / 100.0f, Random.Range (0, 1000) / 100.0f), row.transform.rotation).transform) {
							child.gameObject.GetComponent<Renderer> ().material = mt;
						}
					}
				}
			}
		}
	}
}