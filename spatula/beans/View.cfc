component
	accessors=true
{
	//Properties
	property type="String" name="title";
	property type="String" name="content";
	property type="String" name="template";
	property type="String" name="display";
	property type="String" name="format";
	property type="Struct" name="data";

	//Constructors
	public View function init(
		String title = "",
		String content = "",
		String template = "",
		String display = "",
		String format = "",
		Struct data = {}
	)
	{
		variables.title = arguments.title;
		variables.content = arguments.content;
		variables.template = ( len( trim( arguments.template ) ) == 0 ? "Default" : arguments.template );
		variables.display = ( len( trim( arguments.display ) ) == 0 ? "Default" : arguments.display );
		variables.format = ( len( trim( arguments.format ) ) == 0 ? "html" : arguments.format );
		variables.data = arguments.data;

		return this;
	}

	//Business Logic
	public String function getFormattedContent()
	{
		var formattedContent = "";

		switch( variables.display )
		{
			case "wiki":
				formattedContent = createObject( "component", "spatula.textparsers.WikiParser" )
					.parseText( variables.content );

				break;

			default:
				formattedContent = variables.content;
				break;
		}

		return formattedContent;
	}
}