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

		if ( structKeyExists( this, arguments.view ) )
		{
			var controllerFunction = this[ arguments.view ];
			params = controllerFunction();
		}

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

		var viewObject = createObject( "component", "spatula.bean.View" )
			.init(
				title = title,
				content = content,
				template = template
			);

		return viewObject;
	}

	public String function include(
		required String template,
		required Struct params
	)
	{
		return createObject( "component", "utils.Include" ).init( argumentCollection = arguments );
	}

	public void function onMissingMethod(
		String method,
		Struct args
	)
	{
		return {};
	}
}