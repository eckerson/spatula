component
	accessors=true
{

	public ObjectLibraryService function init()
	{
		return this;
	}

	public any function get(
		required String library,
		required String classpath
	)
	{
		var libraryConfig = getLibraryConfig();

		if ( structKeyExists( libraryConfig, arguments.library ) )
		{
			libraryConfig = libraryConfig[ arguments.library ].get();

			for ( var scope in libraryConfig )
			{
				for ( var i = 1; i <= arrayLen( libraryConfig[ scope ] ); i++ )
				{
					var classpathToCompare = libraryConfig[ scope ][ i ].rootPackage & "." & arguments.classpath;

					if ( classpathToCompare == libraryConfig[ scope ][ i ].classpath )
					{
						return getLibrary( arguments.library, scope ).get( arguments.classpath );
					}
				}
			}
		}

		return;
	}

	public any function getLibrary(
		required String library,
		String scope = "application"
	)
	{
		if( isDefined( "#arguments.scope#.#arguments.library#" ) )
		{
			return evaluate( "#arguments.scope#.#arguments.library#" );
		}
	}

	public Struct function getLibraryConfigObject()
	{
		return application.libraryConfig;
	}

	public Struct function getLibraryConfig()
	{
		return getLibraryConfigObject().getLibraryConfig();
	}

	public void function createLibraryConfig(
		Boolean useLazyLoadByDefault = true
	)
	{
		application.libraryConfig = createObject(
			"component",
			"spatula.factories.LibraryConfigFactory"
		).init( arguments.useLazyLoadByDefault );

		application.libraryConfig.createLibraryConfig();
	}

	public void function createLibraries(
		String scope = "application"
	)
	{
		var libraries = structKeyArray( getLibraryConfig() );

		for ( var i = 1; i <= arrayLen( libraries ); i++ )
		{
			"#arguments.scope#.#libraries[ i ]#" = createObject(
				"component",
				"spatula.factories.ObjectFactory"
			).init(
				libraries[ i ],
				arguments.scope
			);
		}
	}

}