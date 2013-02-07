component
	extends = "spatula.Base"

	scope = "request"
	dependencies = "foo.Object2,foo.Object3" //This is a list
	constructorArgs = "crypto:c[spatula.utils.Crypto]" //This is also a list ("key:value,key:value")
{
	//One way to access service objects (requires extending "spatula.Base")
	this.object2 = spatula.get( "services", "foo.Object2" );

	//Alternate way to access service objects (directly calling the object factory)
	//this.object2 = application.services.get( "foo.Object2" );


	public any function init(
		required spatula.utils.Crypto crypto
	)
	{
		this.crypto = arguments.crypto;

		return this;
	}
}