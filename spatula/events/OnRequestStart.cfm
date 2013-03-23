<cfscript>
	//Param required arguments
	param type="String" name="arguments.targetPage";

	//ColdFusion application events by-query-string
	if ( structKeyExists( url, "resetApplication" ) &&
		url.resetApplication == true )
	{
		onApplicationEnd( application );
		onApplicationStart();
	}

	if ( structKeyExists( url, "resetSession" ) &&
		url.resetSession == true )
	{
		onSessionEnd( session, application );
		onSessionStart();
	}

	//Parse the request variables
	createObject( "component", "spatula.utils.RequestParser" )
		.init(
			controllerStyle = config.get( "MVC.CONTROLLER_STYLE", "Framework" ),
			defaultController = config.get( "MVC.DEFAULT_CONTROLLER", "Framework" ),
			defaultView = config.get( "MVC.DEFAULT_VIEW", "Framework" )
		)
		.parseRequest( cgi, url, form );

	//Create the object factories
	spatula.createLibraries(
		"request"
	);
</cfscript>