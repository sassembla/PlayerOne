using System.Collections.Generic;
using MiniJSONForPlayerOne;

public class Commands {

	public class SetId : JSONString {
		public SetId (string identity) {
			this["command"] = "setId";
			this["playerId"] = identity;
		}
	}
	

	public class Log : JSONString {
		public Log (string identity, string log) {
			this["command"] = "logging";
			this["playerId"] = identity;
			this["log"] = log;
		}
	}

	public class JSONString : Dictionary<string, object> {
		public override string ToString () {
			return Json.Serialize(this);
		}
	}

	

}