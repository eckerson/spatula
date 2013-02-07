<cfscript>
	//Param required arguments
	param type="String" name="arguments.targetPage";

	//Generate the content
	local.controllerService = createObject( "component", "spatula.service.ControllerService" ).init();
	local.view = local.controllerService
		.generateView(
			controller = request.controller,
			view = request.view
		);

	if ( isInstanceOf( local.view, "spatula.bean.View" ) )
	{
		variables.content = local.view.getContent();
		variables.title = local.view.getTitle();
		local.template = "/lib/template/" & local.view.getTemplate() & ".cfm";

		//Include the template
		include local.template;
	}

	//TODO: Make this able to occur as a fallback
	//include arguments.targetPage;
</cfscript>