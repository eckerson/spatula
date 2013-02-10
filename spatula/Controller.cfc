component
	extends="Base"
{
	public bean.View function renderView(
		required String controller,
		required String view
	)
	{
		var params = {};
		var title = replace( arguments.view, "_", " ", "all" );
		var template = "Default";
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
			
			var viewPath = "/lib/view/" & lcase( arguments.controller ) & "/" & arguments.view & ".cfm";
			var content = include( template = viewPath, params = params );

			viewObject = createView(
					title = title,
					content = content,
					template = template
				);
		}
		else
		{
			viewObject = onMissingMethod( arguments.view, arguments );
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

	private bean.View function createView(
		String title,
		String content,
		String template
	)
	{
		return createObject( "component", "bean.View" )
			.init( argumentCollection = arguments );
	}

	public any function onMissingMethod(
		String method,
		Struct args
	)
	{
		var content = include(
				template = "/lib/template/error/MissingViewFunction.cfm",
				params = {}
			);
		var viewObject = createView(
				title = "View not Found",
				content = content
			);

		return viewObject;
	}
}