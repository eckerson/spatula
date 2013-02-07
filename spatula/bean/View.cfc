component
	accessors=true
{
	//Properties
	property type="String" name="title";
	property type="String" name="content";
	property type="String" name="template";

	//Constructors
	public View function init(
		String title = "",
		String content = "",
		String template = ""
	)
	{
		variables.title = arguments.title;
		variables.content = arguments.content;
		variables.template = ( len( trim( arguments.template ) ) == 0 ? "Default" : arguments.template );

		return this;
	}
}