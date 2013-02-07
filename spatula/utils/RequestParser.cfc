component
{
	//Constructors
	public void function parseRequest(
		required Struct cgiScope,
		required Struct urlScope,
		required Struct formScope
	)
	{
		parseURI(
			arguments.cgiScope
		);
		parsePathInfo(
			arguments.cgiScope,
			arguments.urlScope,
			arguments.formScope
		);
	}

	private void function parseURI(
		required Struct cgiScope
	)
	{
		var URI = "http://" & arguments.cgiScope[ "server_name" ] & arguments.cgiScope[ "script_name" ];
		var fullURI = URI & arguments.cgiScope[ "path_info" ] & arguments.cgiScope[ "query_string" ];

		request.URI = URI;
		request.fullURI = fullURI;
	}

	/*
	 * This function handles parsing the cgi.path_info into the request scope.
	 * The first value found is the namespace:page.
	 * Any additional values are key:value parameters.
	 **/
	private void function parsePathInfo(
		required Struct cgiScope,
		required Struct urlScope,
		required Struct formScope
	)
	{
		var configService = createObject( "component", "spatula.service.ConfigService" ).init();
		var pathInfo = listToArray( arguments.cgiScope[ "path_info" ], "/" );
		var controller = "";
		var view = "";
		var parameters = {};
		var thisParam = 0;

		//Append the url and form scopes into the parameters struct
		structAppend( parameters, arguments.urlScope, false );
		structAppend( parameters, arguments.formScope, true );

		//Get the controller and view from the path info
		if ( arrayLen( pathInfo ) >= 2 )
		{
			controller = pathInfo[ 1 ];
			view = pathInfo[ 2 ];
		}
		else if ( arrayLen( pathInfo ) == 1 )
		{
			controller = pathInfo[ 1 ];
			view = configService.get( "DEFAULT_VIEW" );
		}
		else
		{
			redirectToPage(
				configService.get( "DEFAULT_CONTROLLER" ),
				configService.get( "DEFAULT_VIEW" ),
				arguments.cgiScope
			);
		}

		//Get the parameters from the path info
		for ( var i = 3; i <= arrayLen( pathInfo ); i++ )
		{
			thisParam = listToArray( pathInfo[ i ], ":" );

			if ( !structKeyExists( parameters, thisParam[ 1 ] ) )
			{
				parameters[ thisParam[ 1 ] ] = "";
			}

			if ( arrayLen( thisParam ) > 1 )
			{
				parameters[ thisParam[ 1 ] ] = listAppend( parameters[ thisParam[ 1 ] ], thisParam[ 2 ] );
			}
		}

		request.parameters = parameters;
		request.controller = controller;
		request.view = view;
	}

	private void function redirectToPage(
		required String controller,
		required String view,
		required Struct cgiScope
	)
	{
		var locationURL = "http://" & arguments.cgiScope[ "server_name" ] & arguments.cgiScope[ "script_name" ] & "/";

		if ( len( trim( arguments.controller ) ) )
		{
			locationURL &= arguments.controller & "/";
		}

		locationURL &= arguments.view;


		location( locationURL, false );
	}
}