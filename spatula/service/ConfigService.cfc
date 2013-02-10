component
	accessors=true
{
	//Properties
	property type="String" name="configRoot" setter=false;

	//Constructors
	public ConfigService function init()
	{
		variables.configRoot = "/lib/config/";

		return this;
	}

	//Accessors
	public any function get(
		required String key,
		String configName = "Application"
	)
	{
		if ( structKeyExists( application, arguments.configName & "Config" ) )
		{
			return application[ arguments.configName & "Config" ].get( arguments.key );
		}
	}

	//Business Logic
	public void function createConfigs()
	{
		var configFiles = directoryList( expandPath( variables.configRoot ), false, "name", "*.json" );

		for ( var i = 1; i <= arrayLen( configFiles ); i++ )
		{
			createConfig( configFiles[ i ] );
		}
	}

	public void function createConfig(
		required String configFile
	)
	{
		var configName = reReplaceNoCase( arguments.configFile, ".json$", "" );
		var configPath = variables.configRoot & arguments.configFile;
		var jsonConfig = fileRead( expandPath( configPath ) );
		var configObject = deserializeJSON( jsonConfig );
		var configCache = createObject( "component", "spatula.bean.Cache" )
			.init(
				cache = configObject,
				isFinalized = true
			);

		application[ configName & "Config" ] = configCache;
	}
}