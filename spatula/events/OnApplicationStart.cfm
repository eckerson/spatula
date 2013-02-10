<cfscript>
	//Create the site configuration
	config.createConfigs();

	//Create the library configurations
	spatula.createLibraryConfig(
		"services,models",
		"lib.com.service,lib.com.model"
	);

	//Create the object factories
	spatula.createLibraries(
		"application"
	);
</cfscript>