component
	accessors = true
{
	//Properties
	property type="String" name="type";
	property type="any" name="content";

	//Constructors
	public Response function init()
	{
		variables.type = "OK";
		variables.content = "";

		return this;
	}
}