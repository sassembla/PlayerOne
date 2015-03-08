using UnityEngine;
using System.Collections.Generic;


class PlayerOne : MonoBehaviour {
	
	public static USSAWebSocketSharp.WebSocket ws;

	public void Start () {
		// start websocket connect
		ws = new USSAWebSocketSharp.WebSocket("ws://127.0.0.1:80/client");

		ws.OnOpen += (sender, e) => {
			Debug.Log("connected!:" + e);
		};

		ws.OnMessage += (sender, e) => {
			Debug.Log("message received!:" + e.Data);
		};

		ws.OnError += (sender, e) => {
			Debug.Log("disconnected:" + e.Message);
		};

		ws.OnClose += (sender, e) => {
			Debug.Log("closed:" + e.Reason);
		};
		
		ws.Connect();
	}
}