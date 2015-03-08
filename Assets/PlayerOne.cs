using UnityEngine;



class PlayerOne : MonoBehaviour {
	
	public static USSAWebSocketSharp.WebSocket ws;

	public void Start () {
		// start websocket connect
		ws = new USSAWebSocketSharp.WebSocket("ws://127.0.0.1:80/client");

		ws.OnOpen += (sender, e) => {
			Debug.Log("connected!");
		};

		ws.OnMessage += (sender, e) => {
			Debug.Log("message received!:" + e.Data);
		};

		ws.OnError += (sender, e) => {};

		ws.OnClose += (sender, e) => {};
		
		ws.Connect();
	}



}