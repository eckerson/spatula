<cfscript>
	//Create the site configuration
	config.createConfigs();

	//Create the library configurations
	spatula.createLibraryConfig(
		config.get( "OBJECT_CACHING.DEFAULT_LAZY_LOAD", "Framework" )
	);

	//Create the object factories
	spatula.createLibraries(
		"application"
	);
</cfscript>