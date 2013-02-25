<cfscript>
	//Param required arguments
	param type="String" name="arguments.targetPage";

	//Generate the content
	local.controllerService = createObject( "component", "spatula.services.ControllerService" ).init();
	local.view = local.controllerService
		.generateView(
			controller = request.controller,
			view = request.view
		);

	if ( isInstanceOf( local.view, "spatula.beans.View" ) )
	{
		variables.content = local.view.getFormattedContent();
		variables.title = local.view.getTitle();
		local.template = "/app/templates/" & local.view.getTemplate() & ".cfm";

		//Include the template
		include local.template;
	}

	//TODO: Make this able to occur as a fallback
	//include arguments.targetPage;
</cfscript>