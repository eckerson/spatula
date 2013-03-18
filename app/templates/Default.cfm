<!DOCTYPE html>
<cfscript>
	//Param required variables
	param type="String" name="variables.content";
	param type="String" name="variables.title";
</cfscript>
<html>
<head>
	<cfoutput>
		<title>#variables.title# | #config.get( "site_name" )#</title>
	</cfoutput>

	<link rel="stylesheet" type="text/css" href="/app/css/Application.css" />
</head>
<body>
	<cfoutput>
		<h1>#variables.title#</h1>

		#variables.content#
	</cfoutput>
</body>
</html>