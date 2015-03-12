using UnityEngine;

using System;
using System.Collections.Generic;

using wsControl;


class PlayerOne : MonoBehaviour {

	// generate uuid if new.
	public readonly string userId = "200";//Guid.NewGuid().ToString();
	
	private int localFrame;

	public void Awake () {
		
		WebSocketConnectionController.Init(
			userId,

			// connected
			() => {
				Debug.Log("connect succeeded!");
				Application.logMessageReceived += HandleLog;

				WebSocketConnectionController.SendCommand(new Commands.SetId(userId).ToString());
			},

			// messages comes from server
			(List<string> datas) => {
				Debug.Log("datas received:" + datas.Count);
				foreach (var data in datas) {
					Debug.Log("data:" + data + " in localFrame:" + localFrame);
				}
				transform.Translate(new Vector3(100, 100, 100));
			},

			// connect fail
			(string connectionFailReason) => {
				Debug.Log("failed to connect! by reason:" + connectionFailReason);
			},

			// error on connection
			(string connectionError) => {
				Debug.Log("failed in running! by reason:" + connectionError);
			},

			// auto reconnect
			true,
			() => {
				Debug.Log("reconnecting!");
			}
		);
	}

	public void Update () {
		// Debug.Log("up!");
		localFrame++;
	}

	public void OnApplicationQuit () {
		Debug.Log("exitting..");
		WebSocketConnectionController.CloseCurrentConnection();
	}



	

	/**
		send log to server.
	*/
	void HandleLog(string logString, string stackTrace, LogType type) {
		WebSocketConnectionController.SendCommand(new Commands.Log(userId, logString).ToString());
    }



}