component
	accessors=true
{
	//Properties
	property type="String" name="title";
	property type="String" name="content";
	property type="String" name="template";
	property type="String" name="format";

	//Constructors
	public View function init(
		String title = "",
		String content = "",
		String template = "",
		String format = ""
	)
	{
		variables.title = arguments.title;
		variables.content = arguments.content;
		variables.template = ( len( trim( arguments.template ) ) == 0 ? "Default" : arguments.template );
		variables.format = ( len( trim( arguments.format ) ) == 0 ? "Default" : arguments.format );

		return this;
	}

	//Business Logic
	public String function getFormattedContent()
	{
		var formattedContent = "";

		switch( variables.format )
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