component
	extends="Base"
{
	variables.title = "";
	variables.template = "Default";
	variables.display = "Default";
	variables.format = "html";

	public beans.View function renderView(
		required String controller,
		required String view
	)
	{
		var params = {};
		var viewObject = 0;
		var content = "";

		variables.title = replace( arguments.view, "_", " ", "all" );

		if ( structKeyExists( this, arguments.view ) )
		{
			var controllerFunction = this[ arguments.view ];
			params = controllerFunction();
			
			var viewPath = "/app/views/" & lcase( arguments.controller ) & "/" & arguments.view & ".cfm";
			var content = include( template = viewPath, params = params );

			viewObject = createView(
					title = variables.title,
					content = content,
					template = variables.template,
					display = variables.display,
					format = variables.format,
					data = params
				);
		}
		else
		{
			viewObject = onMissingControllerMethod( arguments.controller, arguments.view );
		}

		return viewObject;
	}

	private String function include(
		required String template,
		required Struct params
	)
	{
		return createObject( "component", "utils.Include" ).init( argumentCollection = arguments );
	}

	private beans.View function createView(
		String title,
		String content,
		String template,
		String display,
		String format,
		Struct data
	)
	{
		if ( structKeyExists( request.parameters, "display" ) )
		{
			arguments.display = request.parameters.display;
		}

		if ( structKeyExists( request.parameters, "format" ) )
		{
			arguments.format = request.parameters.format;
		}

		return createObject( "component", "beans.View" )
			.init( argumentCollection = arguments );
	}

	public beans.View function onMissingControllerMethod(
		required String controller,
		required String view
	)
	{
		var content = include(
				template = "/app/templates/error/MissingControllerMethod.cfm",
				params = {
					controller = arguments.controller,
					view = arguments.view
				}
			);
		var viewObject = createView(
				title = "View not Found",
				content = content
			);

		return viewObject;
	}

}