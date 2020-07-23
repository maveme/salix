function registerBlockly(salix) {
	
	var workspaces = {};

	salix.Decoders.blocklyChange = function (args) {
		return function (event) {
			if(event.type != "ui"){
				var workspace = Blockly.Workspace.getById(event.workspaceId);
				var code = Blockly.JavaScript.workspaceToCode(workspace);
				return {type: "blocklyChange",
						msg: code
				};
			};
			return;
		};
	};

	
	// Salix
	function myBlockly(attach, id, attrs, props, events, extra){
		
		// Salix
		var div = document.createElement('div');
		div.setAttribute("id", "blocklyDiv");
		div.setAttribute("style", "height:480px; width:100%");
		attach(div);

        // Create Blockly		
		var workspace = Blockly.inject('blocklyDiv', {toolbox: document.getElementById('toolbox')});
		workspaces[id] = workspace;
		
		// Salix
		var myHandlers = {};
		
		for (var key in props){
			if(props.hasOwnProperty(key)){
				var val = props[key];
				
				switch(key){
					case 'toolbox':
						console.log(val);
						break;
					default:
					    break;
				}
			}
		}
		
		for (var key in events) {
			if (events.hasOwnProperty(key)) {
				var handler = salix.getNativeHandler(events[key]);
				myHandlers[key] = handler;
				workspace.addChangeListener(handler);
			}	
		}

        // Salix
        function patch(edits, attach){
	      edits = edits || [];

		  // Salix
          for (var i = 0; i < edits.length; i++){
		    var edit = edits[i];
		    var type = salix.nodeType(edit);
			
			//Salix	
			switch (type) {
			  default:
			    throw 'unsupported edit: ' + JSON.stringify(edit);
			}
          }
        }
		
		//Salix
		div.salix_native = {patch: patch};
		return div;
	}
	
	//Salix
	salix.registerNative('blockly', myBlockly);
};