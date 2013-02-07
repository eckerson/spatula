<cfscript>
	//Param required arguments
	param type="String" name="arguments.targetPage";

	//Parse the request variables
	createObject( "component", "spatula.utils.RequestParser" ).parseRequest( cgi, url, form );

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

	//Create the object factories
	spatula.createLibraries(
		"request"
	);
</cfscript>