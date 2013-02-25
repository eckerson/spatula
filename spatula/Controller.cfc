component
	extends="Base"
{
	public beans.View function renderView(
		required String controller,
		required String view
	)
	{
		var params = {};
		var title = replace( arguments.view, "_", " ", "all" );
		var template = "Default";
		var format = "Default";
		var viewObject = 0;

		if ( structKeyExists( this, arguments.view ) )
		{
			var controllerFunction = this[ arguments.view ];
			params = controllerFunction();

			if ( structKeyExists( params, "title" ) &&
				len( trim( params.title ) ) > 0 )
			{
				title = params.title;
			}

			if ( structKeyExists( params, "template" ) &&
				len( trim( params.template ) ) )
			{
				template = params.template;
			}

			if ( structKeyExists( params, "format" ) &&
				len( trim( params.format ) ) )
			{
				format = params.format;
			}
			
			var viewPath = "/app/views/" & lcase( arguments.controller ) & "/" & arguments.view & ".cfm";
			var content = include( template = viewPath, params = params );

			viewObject = createView(
					title = title,
					content = content,
					template = template,
					format = format
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
		String template
	)
	{
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