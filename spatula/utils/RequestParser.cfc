component
	accessors=true
{
	//Properties
	property type="String" name="controllerStyle";
	property type="String" name="controllerDelimiter";
	property type="String" name="defaultController";
	property type="String" name="defaultView";

	//Constructors
	public RequestParser function init(
		String controllerStyle = "default",
		String controllerDelimiter = "/",
		String defaultController = "Main",
		String defaultView = "Home"
	)
	{
		variables.controllerStyle = arguments.controllerStyle;
		variables.controllerDelimiter = arguments.controllerDelimiter;
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

	/*
	 * This function removes the script_name from the beginning of the path_info.
	 * This is necessary for Windows Servers, which can include that information
	 * in the path_info, even though the framework doesn't need it there.
	 **/
	private String function cleanPathInfo(
		required Struct cgiScope
	)
	{
		var pathInfo = arguments.cgiScope[ "path_info" ];
		var scriptName = arguments.cgiScope[ "script_name" ];

		pathInfo = reReplaceNoCase( pathInfo, "^" & scriptName, "", "one" );

		return pathInfo;
	}

	private void function parseURI(
		required Struct cgiScope
	)
	{
		var pathInfo = cleanPathInfo( cgiScope = arguments.cgiScope );
		var URI = "http://" & arguments.cgiScope[ "server_name" ] & arguments.cgiScope[ "script_name" ];
		var fullURI = URI;

		if ( len( pathInfo ) )
		{
			fullURI &= pathInfo;
		}

		if ( len( arguments.cgiScope[ "query_string" ] ) )
		{
			fullURI &= "?" & arguments.cgiScope[ "query_string" ];
		}

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
		var pathInfo = listToArray( cleanPathInfo( cgiScope = arguments.cgiScope ), "/" );
		var parameters = {};
		var thisParam = 0;
		var parsedPath = {
			controller = "",
			view = "",
			parameterStartIndex = 1
		};

		//Get the controller and view from the path info
		if ( variables.controllerDelimiter == "/" )
		{
			/*
			 * Because the delimiter is the same as the directory delimiter,
			 * The framework needs to use the first two array positions for the
			 * controller and view.
			 **/
			parsedPath.parameterStartIndex = 3;

			if ( arrayLen( pathInfo ) >= 2 )
			{
				parsedPath.controller = pathInfo[ 1 ];
				parsedPath.view = pathInfo[ 2 ];
			}
			else if ( arrayLen( pathInfo ) == 1 )
			{
				if ( variables.controllerStyle == "wiki" )
				{
					parsedPath.controller = variables.defaultController;
					parsedPath.view = pathInfo[ 1 ];
				}
				else
				{
					parsedPath.controller = pathInfo[ 1 ];
					parsedPath.view = variables.defaultView;
				}
			}
		}
		else
		{
			/*
			 * Any other character used as a delimiter will be contained in
			 * the first position of the path_info.
			 **/
			var parsedPath.parameterStartIndex = 2;

			if ( arrayLen( pathInfo ) > 0 &&
				find( variables.controllerDelimiter , pathInfo[ 1 ] ) )
			{
				var thisParam = listToArray( pathInfo[ 1 ], variables.controllerDelimiter, true );

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
			else if ( arrayLen( pathInfo ) > 0 )
			{
				if ( variables.controllerStyle == "wiki" )
				{
					parsedPath.controller = variables.defaultController;
					parsedPath.view = pathInfo[ 1 ];
				}
				else
				{
					parsedPath.controller = pathInfo[ 1 ];
					parsedPath.view = variables.defaultView;
				}
			}
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
				locationURL &= arguments.controller & variables.controllerDelimiter;
			}

			locationURL &= arguments.view;
		}
		else
		{
			locationURL &= arguments.controller;

			if ( len( trim( arguments.view ) ) )
			{
				locationURL &= variables.controllerDelimiter & arguments.view;
			}
		}

		location( locationURL, false );
	}
}