using UnityEngine;
using System.Collections;

public class Fleet : MonoBehaviour
{
	IEnumerator Start () {
		while (true) {
			// spaceship.Shot (transform);
			// audio.Play ();
			yield return new WaitForSeconds (1);
		}
	}

	void Update () {
		float x = Input.GetAxisRaw ("Horizontal");
		float y = Input.GetAxisRaw ("Vertical");
		Vector2 direction = new Vector2(x, y).normalized;
		Move(direction);
	}

	void Move (Vector2 direction) {
		Vector2 min = Camera.main.ViewportToWorldPoint(new Vector2 (0, 0));
		Vector2 max = Camera.main.ViewportToWorldPoint(new Vector2 (1, 1));

		Vector2 pos = transform.position;

		pos += direction * 1 * Time.deltaTime;

		pos.x = Mathf.Clamp(pos.x, min.x, max.x);
		pos.y = Mathf.Clamp(pos.y, min.y, max.y);

		transform.position = pos;
	}
}
