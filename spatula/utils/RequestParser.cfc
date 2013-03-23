component
	accessors=true
{
	//Properties
	property type="String" name="controllerStyle";
	property type="String" name="defaultController";
	property type="String" name="defaultView";

	//Constructors
	public RequestParser function init(
		String controllerStyle = "default",
		String defaultController = "Main",
		String defaultView = "Home"
	)
	{
		variables.controllerStyle = arguments.controllerStyle;
		variables.defaultController = arguments.defaultController;
		variables.defaultView = arguments.defaultView;

		return this;
	}

	//Controllers
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
	 * When using the wiki format, the first value found is the controller:view.
	 * When using the default format, the first value found is the controller, the second is the view.
	 * Any additional values are key:value parameters.
	 * The URL Scope will overwrite parameters.
	 * The FORM Scope will overwrite parameters and the URL Scope.
	 **/
	private void function parsePathInfo(
		required Struct cgiScope,
		required Struct urlScope,
		required Struct formScope
	)
	{
		var configService = createObject( "component", "spatula.services.ConfigService" ).init();
		var pathInfo = listToArray( arguments.cgiScope[ "path_info" ], "/" );
		var parameters = {};
		var thisParam = 0;
		var parsedPath = {};

		//Get the controller and view from the path info
		if ( variables.controllerStyle == "wiki" )
		{
			parsedPath = parseWikiPath( pathInfo );
		}
		else
		{
			parsedPath = parseDefaultPath( pathInfo );
		}
		
		if ( parsedPath.controller == "" &&
			parsedPath.view == "" )
		{
			redirectToPage(
				variables.defaultController,
				variables.defaultView,
				arguments.cgiScope
			);
		}

		//Get the parameters from the path info
		for ( var i = parsedPath.parameterStartIndex; i <= arrayLen( pathInfo ); i++ )
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

		//Append the url and form scopes into the parameters struct
		structAppend( parameters, arguments.urlScope, false );
		structAppend( parameters, arguments.formScope, true );

		request.parameters = parameters;
		request.controller = parsedPath.controller;
		request.view = parsedPath.view;
	}

	private Struct function parseWikiPath(
		required Array pathInfo
	)
	{
		var parsedPath = {
			controller = "",
			view = "",
			parameterStartIndex = 2
		};

		if ( arrayLen( arguments.pathInfo ) > 0 &&
			find( ":" , arguments.pathInfo[ 1 ]) )
		{
			var thisParam = listToArray( arguments.pathInfo[ 1 ], ":", true );

			if ( arrayLen( thisParam ) > 0 &&
				len( trim( thisParam[ 1 ] ) ) > 0 )
			{
				parsedPath.controller = thisParam[ 1 ];
			}

			if ( arrayLen( thisParam ) > 1 &&
				len( trim( thisParam[ 2 ] ) ) > 0 )
			{
				parsedPath.view = thisParam[ 2 ];
			}
		}
		else if ( arrayLen( arguments.pathInfo ) > 0 &&
			"/" & arguments.pathInfo[ 1 ] != arguments.cgiScope.script_name ) //Windows Servers append the script_name to the pathInfo
		{
			parsedPath.controller = variables.defaultController;
			parsedPath.view = arguments.pathInfo[ 1 ];
		}

		return parsedPath;
	}

	private Struct function parseDefaultPath(
		required Array pathInfo
	)
	{
		var parsedPath = {
			controller = "",
			view = "",
			parameterStartIndex = 3
		};

		if ( arrayLen( arguments.pathInfo ) >= 2 )
		{
			parsedPath.controller = arguments.pathInfo[ 1 ];
			parsedPath.view = arguments.pathInfo[ 2 ];
		}
		else if ( arrayLen( arguments.pathInfo ) == 1 &&
			"/" & arguments.pathInfo[ 1 ] != arguments.cgiScope.script_name ) //Windows Servers append the script_name to the pathInfo
		{
			parsedPath.controller = arguments.pathInfo[ 1 ];
			parsedPath.view = variables.defaultView;
		}

		return parsedPath;
	}

	private void function redirectToPage(
		required String controller,
		required String view,
		required Struct cgiScope
	)
	{
		var locationURL = "http://" & arguments.cgiScope[ "server_name" ] & arguments.cgiScope[ "script_name" ] & "/";

		if ( variables.controllerStyle == "wiki" )
		{
			if ( len( trim( arguments.controller ) ) )
			{
				locationURL &= arguments.controller & ":";
			}

			locationURL &= arguments.view;
		}
		else
		{
			locationURL &= arguments.controller;

			if ( len( trim( arguments.view ) ) )
			{
				locationURL &= "/" & arguments.view;
			}
		}

		location( locationURL, false );
	}
}