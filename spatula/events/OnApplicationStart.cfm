<cfscript>
	//Create the site configuration
	config.createConfigs();

	//Create the library configurations
	spatula.createLibraryConfig(
		config.get( "DEFAULT_LAZY_LOAD" )
	);

	//Create the object factories
	spatula.createLibraries(
		"application"
	);
</cfscript>