<cfscript>
	//Create the site configuration
	config.createConfigs();

	//Create the library configurations
	spatula.createLibraryConfig(
		"services,models",
		"app.lib.service,app.lib.model",
		config.get( "DEFAULT_LAZY_LOAD" )
	);

	//Create the object factories
	spatula.createLibraries(
		"application"
	);
</cfscript>