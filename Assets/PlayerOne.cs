using UnityEngine;

using System.Collections.Generic;

using ClientLSWebSocket;

class PlayerOne : MonoBehaviour {
	
	public static WebSocket webSocket;

	public void Start () {
		// start websocket connect
		webSocket = new WebSocket("ws://127.0.0.1:80/client");

		webSocket.OnOpen += (sender, e) => {
			Debug.Log("connected!:" + e);
		};

		webSocket.OnMessage += (sender, e) => {
			Debug.Log("message received!:" + e.Data);
		};

		webSocket.OnError += (sender, e) => {
			Debug.Log("disconnected:" + e.Message);
		};

		webSocket.OnClose += (sender, e) => {
			Debug.Log("closed:" + e.Reason);
		};
		
		webSocket.Connect();
	}
}