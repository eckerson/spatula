/**
 * This object acts as a proxy to encapsulate the variables scope of the called
 * template for use with CFC-CFM mixins without allowing the CFM's variables
 * bleeding into the CFC's variables.
 *
 * This concept was taken from Tony Nelson at:
 * http://bears-eat-beets.blogspot.com/2009/01/coldfusion-mixins.html
 */
component
{
	public String function init(
		required String template,
		required Struct params
	)
	{
		structDelete( variables, "init" );
		structDelete( variables, "this" );
		structAppend( variables, arguments.params );

		savecontent variable="local.html"
		{
			include arguments.template;
		}

		return local.html;
	}
}