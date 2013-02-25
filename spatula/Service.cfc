component
	extends="Base"
{
	public beans.Response function getNewResponse()
	{
		return createObject( "component", "beans.Response" ).init();
	}
}