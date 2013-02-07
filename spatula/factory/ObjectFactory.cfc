component
	accessors=true
	extends="spatula.Base"
{
	property type="Struct" name="objects" setter=false;
	property type="Array" name="config" setter=false;

	public ObjectFactory function init(
		required String library,
		required String scope
	)
	{
		//Set the properties to their default values
		variables.objects = createObject(
			"component",
			"spatula.bean.Cache"
		).init();
		variables.config = spatula.getLibraryConfig()[ arguments.library ].get( arguments.scope );

		//Load the objects in the library
		loadObjects(
			arguments.library,
			arguments.scope
		);

		return this;
	}

	public any function get(
		String classpath = ""
	)
	{
		return variables.objects.get( arguments.classpath );
	}

	private void function loadObjects()
	{
		for ( var i = 1; i <= arrayLen( variables.config ); i++ )
		{
			loadObject(
				variables.config[ i ].classpath,
				variables.config[ i ]
			);
		}
	}

	private void function loadObject(
		required String classpath,
		Struct config
	)
	{
		if ( !structKeyExists( arguments, "config" ) )
		{
			arguments.config = getObjectConfigByClasspath(
				arguments.classpath
			);
		}

		//Load dependencies
		loadDependencies(
			arguments.config.dependencies
		);

		//Parse constructor args
		var constructorArgs = duplicate( arguments.config.constructorArgs );
		parseConstructorArgs( constructorArgs );

		var object = createObject(
			"component",
			arguments.classpath
		);

		if ( structKeyExists( object, "init" ) )
		{
			object = object.init(
				argumentCollection = constructorArgs
			);
		}

		var objectClasspath = replaceNoCase( arguments.classpath, arguments.config.rootPackage & ".", "", "one" );

		variables.objects.set(
			objectClasspath,
			object
		);
	}

	private void function loadDependencies(
		required Array dependencies
	)
	{
		var config = {};
		var classpath = 0;

		for ( var i = 1; i <= arrayLen( arguments.dependencies ); i++ )
		{
			classpath = arguments.dependencies[ i ];
			config = getObjectConfigByClasspath( classpath );

			if ( structIsEmpty( config ) )
			{
				//Object is not managed by this factory
				config = spatula.getLibraryConfigObject().getObjectConfigByClasspath( classpath );

				if ( !structIsEmpty( config ) )
				{
					var library = spatula.getLibrary( config.library, config.scope );

					if ( !isNull( library ) )
					{
						var object = library.get( classpath );

						if ( isNull( object ) ||
							!isObject( object ) )
						{
							//Load the object
							library.loadObject(
								classpath,
								config
							);
						}
					}
				}

			}
			else
			{
				//Object is managed by this factory
				loadObject(
					classpath,
					config
				);
			}
		}
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
		required any constructorArg
	)
	{
		var parsedArg = arguments.constructorArg;
		var dePattern = "^de\[([\w\.\-\'\(\)]*)\]$";
		var key = 0;

		if ( isSimpleValue( parsedArg ) )
		{
			if ( reFindNoCase( dePattern, parsedArg ) )
			{
				key = reReplaceNoCase( parsedArg, dePattern, "\1" );

				try
				{
					parsedArg = evaluate( key );
				}
				catch( any e )
				{}
			}
		}

		return parsedArg;
	}

	private Struct function getObjectConfigByClasspath(
		required String classpath
	)
	{
		var config = {};

		for ( var i = 1; i <= arrayLen( variables.config ); i++ )
		{
			if ( variables.config[ i ].classpath == arguments.classpath )
			{
				config = variables.config[ i ];
				break;
			}
		}

		return config;
	}

}