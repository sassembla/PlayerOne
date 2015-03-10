using UnityEngine;

using System;
using System.Collections.Generic;

using ClientLSWebSocket;

class PlayerOne : MonoBehaviour {

	// generate uuid if new.
	public readonly string userId = Guid.NewGuid().ToString();
	public static WebSocket webSocket;


	public void Awake () {
		// start websocket connect
		webSocket = new WebSocket("ws://127.0.0.1:80/client");

		webSocket.OnOpen += (sender, e) => {
			Application.logMessageReceived += HandleLog;

			SendCommand(new Commands.SetId(userId));
		};

		webSocket.OnMessage += (sender, e) => {
			Debug.Log("message received!:" + e.Data);
		};

		webSocket.OnError += (sender, e) => {
			Debug.Log("disconnected:" + e.Message);

			// 再接続を試みないとな
		};

		webSocket.OnClose += (sender, e) => {
			Debug.Log("closed:" + e.Reason);
		};
		
		webSocket.Connect();
	}

	public void Update () {
		// Debug.Log("up!");
	}

	public void OnApplicationQuit () {
		Debug.Log("exitting..");
		if (webSocket.IsAlive) webSocket.Close();
	}

	public void SendCommand (Commands.JSONString commandSource) {
		if (webSocket.IsAlive) webSocket.Send(commandSource.ToString());
	}




	

	/**
		send log to server.
	*/
	void HandleLog(string logString, string stackTrace, LogType type) {
		SendCommand(new Commands.Log(userId, logString));
    }



}