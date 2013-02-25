component
	accessors = true
{
	//Properties
	property type="Struct" name="cache" setter="false";
	property type="Boolean" name="isFinalized" setter="false";
	property type="Boolean" name="createdOn" setter="false";
	property type="Boolean" name="finalizedOn" setter="false";

	//Constructors
	public Cache function init(
		Struct cache = {},
		Boolean isFinalized = false
	)
	{
		variables.createdOn = now();
		variables.cache = arguments.cache;
		variables.isFinalized = arguments.isFinalized;

		if ( arguments.isFinalized )
		{
			variables.finalizedOn = variables.createdOn;
		}

		this.isFinalized = this.getIsFinalized;

		return this;
	}

	//Controllers
	public void function set(
		required String key,
		required any value
	)
	{
		if ( !variables.isFinalized )
		{
			var variablePathArray = listToArray( arguments.key, "." );
			var currentVariable = variables.cache;
			var thisKey = 0;

			for ( var i = 1; i <= arrayLen( variablePathArray ); i++ )
			{
				thisKey = variablePathArray[ i ];

				if ( i == arrayLen( variablePathArray ) )
				{
					currentVariable[ thisKey ] = arguments.value;
				}
				else
				{
					if ( !structKeyExists( currentVariable, thisKey ) ||
						(
							structKeyExists( currentVariable, thisKey ) &&
							!isStruct( currentVariable[ thisKey ] )
						) )
					{
						currentVariable[ thisKey ] = {};
					}

					currentVariable = currentVariable[ thisKey ];
				}
			}
		}
	}

	public any function get(
		String key = ""
	)
	{
		var variablePathArray = listToArray( arguments.key, "." );
		var currentVariable = duplicate( variables.cache );
		var thisKey = 0;

		for ( var i = 1; i <= arrayLen( variablePathArray ); i++ )
		{
			thisKey = variablePathArray[ i ];

			if ( structKeyExists( currentVariable, thisKey ) )
			{
				currentVariable = currentVariable[ thisKey ];
			}
			else
			{
				//No variable is returned, return null
				return;
			}
		}

		return currentVariable;
	}

	public void function finalize()
	{
		variables.isFinalized = true;
		variables.finalizedOn = now();
	}
}