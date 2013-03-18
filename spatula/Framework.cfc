component
	extends = "Base"
{
	/*
	 * Application Events
	 */
	public Boolean function onApplicationStart()
	{
		include "events/OnApplicationStart.cfm";

		return true;
	}

	public void function onApplicationEnd( applicationScope )
	{
		include "events/OnApplicationEnd.cfm";
	}

	public void function onRequest( String targetPage )
	{
		include "events/OnRequest.cfm";
	}

	public Boolean function onRequestStart( String targetPage )
	{
		include "events/OnRequestStart.cfm";

		return true;
	}

	public void function onRequestEnd( String targetPage )
	{
		include "events/OnRequestEnd.cfm";
	}

	public void function onSessionStart()
	{
		include "events/OnSessionStart.cfm";
	}

	public void function onSessionEnd( sessionScope, applicationScope )
	{
		include "events/OnSessionEnd.cfm";
	}

	public Boolean function onMissingTemplate( String targetPage )
	{
		include "events/OnMissingTemplate.cfm";

		return true;
	}

	public void function onError( exception, eventName )
	{
		include "events/OnError.cfm";
	}

	public void function onMissingMethod( String method, Struct args )
	{
		include "events/OnMissingMethod.cfm";
	}

	public void function onCFCRequest( String cfcname, String method, Struct args )
	{
		include "events/OnCFCRequest.cfm";
	}
}