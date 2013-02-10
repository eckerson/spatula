/*
 * This component handles creating the configuration objects for the specified
 * object library.
 */
component
	accessors=true
{
	// Properties
	property type="Struct" name="libraryConfig" setter=false;
	property type="Boolean" name="useLazyLoadByDefault" setter=false;


	// Constructors
	public LibraryConfigFactory function init(
		Boolean useLazyLoadByDefault = true
	)
	{
		//Set the default values for the properties
		variables.libraryConfig = {};
		variables.useLazyLoadByDefault = arguments.useLazyLoadByDefault;

		//Return a reference to the initialized object
		return this;
	}


	//Accessors
	public Struct function getObjectConfigByClasspath(
		required String classpath
	)
	{
		var config = {};
		var library = 0;
		var scope = 0;
		var thisLibrary = 0;
		var thisScope = 0;

		for ( library in variables.libraryConfig )
		{
			thisLibrary = variables.libraryConfig[ library ].get();
			thisScope = 0;

			for ( scope in thisLibrary )
			{
				thisScope = thisLibrary[ scope ];

				for ( var i = 1; i <= arrayLen( thisScope ); i++ )
				{
					if ( thisScope[ i ].classpath == arguments.classpath )
					{
						config = thisScope[ i ];
						break;
					}
				}

				if ( !structIsEmpty( config ) )
				{
					break;
				}
			}

			if ( !structIsEmpty( config ) )
			{
				break;
			}
		}

		return config;
	}


	// Controllers

	/*
	 * This function handles creating the configuration for the specified
	 * library. The finalized configuration is stored in the application scope
	 * under "application.libraries[library]". Each object's config is stored
	 * in an array for the scope the object is to be cached in.
	 */
	public void function createLibraryConfig(
		required String libraries,
		required String libraryDotPaths
	)
	{
		var libraryArray = listToArray( arguments.libraries, "," );
		var libraryDotPathArray = listToArray( arguments.libraryDotPaths, "," );

		for ( var l = 1; l <= min( arrayLen( libraryArray ), arrayLen( libraryDotPathArray ) ); l++ )
		{
			var library = libraryArray[ l ];
			var libraryDotPath = libraryDotPathArray[ l ];

			var libraryPath = convertToPath(
				libraryDotPath
			);
			var objects = getLibraryObjects(
				libraryPath
			);
			var libraryConfig = {
				application = [],
				request = [],
				session = []
			};
			var objectConfig = 0;
			var dotPath = 0;
			var objectName = 0;
			var classpath = 0;
			var rootPackage = libraryDotPath;

			//Get the config for each object
			for ( var i = 1; i <= objects.recordCount; i++ )
			{
				//Determine object pathing information
				dotPath = convertToDotPath( objects.directory[ i ] );
				objectName = reReplaceNoCase( objects.name[ i ], ".cfc$", "" );
				classpath = dotPath & "." & objectName;

				//Get the config
				objectConfig = getObjectMetaConfig( classpath, library );
				objectConfig[ "rootPackage" ] = rootPackage;

				//Append the object config to the library config
				if ( structKeyExists( libraryConfig, objectConfig.scope ) )
				{
					arrayAppend( libraryConfig[ objectConfig.scope ], objectConfig );
				}

			}

			//Cache the library config
			variables.libraryConfig[ library ] = createObject( "component", "spatula.bean.Cache" ).init(
				libraryConfig,
				true
			);
		}

	}

	private String function convertToPath(
		required String dotPath
	)
	{
		var path = "";

		if ( len( trim( arguments.dotPath ) ) )
		{
			path = "/" & replaceNoCase( arguments.dotPath, ".", "/", "all" );

			path = expandPath( path );
		}

		return path;
	}

	private String function convertToDotPath(
		required String path
	)
	{
		var dotPath = replaceNoCase( arguments.path, expandPath( "/" ), "" );

		dotPath = reReplace( dotPath, "[\\\/]", ".", "all" );

		return dotPath;
	}

	private Query function getLibraryObjects(
		required String rootPath
	)
	{
		return directoryList(
			arguments.rootPath,
			true,
			"Query",
			"*.cfc",
			"directory ASC, name ASC"
		);
	}

	private Struct function getObjectMetaConfig(
		required String classpath,
		required String library
	)
	{
		var objectMetaData = getComponentMetaData( arguments.classpath );
		var config = {
			"library" = arguments.library,
			"classpath" = arguments.classpath,
			"name" = listLast( arguments.classpath, "." ),
			"scope" = "application",
			"lazyLoad" = variables.useLazyLoadByDefault,
			"dependencies" = [],
			"constructorArgs" = {}
		};
		var configObject = 0;

		if ( structKeyExists( objectMetaData, "scope" ) )
		{
			config.scope = objectMetaData.scope;
		}

		if ( structKeyExists( objectMetaData, "lazyLoad" ) &&
			isBoolean( objectMetaData.lazyLoad ) )
		{
			config.lazyLoad = objectMetaData.lazyLoad;
		}

		if  ( structKeyExists( objectMetaData, "dependencies" ) )
		{
			config.dependencies = listToArray( objectMetaData.dependencies, "," );
		}

		if ( structKeyExists( objectMetaData, "constructorArgs" ) )
		{
			var constructorArgsArray = listToArray( objectMetaData.constructorArgs, "," );

			for ( var c = 1; c <= arrayLen( constructorArgsArray ); c++ )
			{
				var thisConstructorArg = listToArray( constructorArgsArray[ c ], ":" );

				if ( arrayLen( thisConstructorArg ) >= 2 )
				{
					config.constructorArgs[ thisConstructorArg[ 1 ] ] = thisConstructorArg[ 2 ];
				}
				else if ( arrayLen( thisConstructorArg ) == 1 )
				{
					config.constructorArgs[ thisConstructorArg[ 1 ] ] = "";
				}
			}
		}

		if ( !structIsEmpty( config.constructorArgs ) )
		{
			parseConstructorArgs(
				config.constructorArgs
			);
		}

		return config;
	}

	private void function parseConstructorArgs(
		required Struct constructorArgs
	)
	{
		var arg = 0;

		for ( arg in arguments.constructorArgs )
		{
			arguments.constructorArgs[ arg ] = parseConstructorArg(
				arguments.constructorArgs[ arg ]
			);
		}
	}

	private any function parseConstructorArg(
		required String constructorArg
	)
	{
		var parsedArg = arguments.constructorArg;
		//var pathPattern = "p\[([\w\.\-]*)\]";
		var componentPattern = "^c\[([\w\.]+)\]$";
		var key = 0;

		/*
		if ( reFindNoCase( pathPattern, parsedArg ) )
		{
			key = reReplaceNoCase( parsedArg, pathPattern, "\1" );

			if ( !isNull( application.paths.get( key ) ) )
			{
				parsedArg = application.paths.get( key );
			}
		}
		*/

		if ( reFindNoCase( componentPattern, parsedArg ) )
		{
			key = reReplaceNoCase( parsedArg, componentPattern, "\1" );

			parsedArg = createObject( "component", key );
		}

		return parsedArg;
	}
}