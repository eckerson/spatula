component
	extends="Base"
{
	public bean.Response function getNewResponse()
	{
		return createObject( "component", "bean.Response" ).init();
	}
}