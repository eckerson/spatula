<cfscript>
	// Param required arguments
	param name="arguments.Exception";
	param name="arguments.EventName";

	local.environmentConfig = config.get( config.get( "CURRENT_ENVIRONMENT", "Environment" ), "Environment" );
	local.exceptionInfo = "";

	if ( local.environmentConfig[ "ERROR_HANDLING" ][ "SHOW_ERRORS" ] )
	{
		local.errorMessage = arguments.Exception.Message;
		if ( structKeyExists( arguments.Exception, "Cause" ) )
		{
			local.errorMessage = arguments.Exception.Cause.Message;
		}
		else if ( structKeyExists( arguments.Exception, "RootCause" ) )
		{
			local.errorMessage = arguments.Exception.RootCause.Message;
		}

		savecontent variable="local.exceptionInfo"
		{
			writeOutput( "<p>&quot;" & local.errorMessage & "&quot;</p>" );

			if ( local.environmentConfig[ "ERROR_HANDLING" ][ "SHOW_FULL_OBJECT" ] )
			{
				writeOutput( "<h2>Error Object</h2>" );
				writeDump( arguments.Exception );
			}
		}
	}
</cfscript>

<cfinclude template="/app/templates/error/Error.cfm" />