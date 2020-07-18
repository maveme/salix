function registerBlockly(salix) {
	
	var workspaces = {};
	
	// Salix
	function myBlockly(attach, id, attrs, props, events, extra){

        // Need to get this out of props or extra. maybe attrs?
		var toolbox = '<xml>';
		toolbox += '  <block type="controls_if"></block>';
        toolbox += '  <block type="controls_whileUntil"></block>';
        toolbox += '</xml>';
		
		// Salix
		var div = document.createElement('div');
		div.setAttribute("id", "blocklyDiv");
		div.setAttribute("style", "height:480px; width:100%");
		attach(div);

        // Create Blockly		
		var workspace = Blockly.inject('blocklyDiv', {toolbox: toolbox});
		workspaces[id] = workspace;
		
		// Salix
		var myHandlers = {};

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