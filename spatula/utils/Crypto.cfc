/**
 * Crypto
 * Script version of CFCrypto
 * Original: https://github.com/virtix/cfcrypto
 **/

component
{
	public Crypto function init()
	{
		return this;
	}

	public String function computeHash
	(
		required String password,
		required String salt,
		Numeric iterations = 1024,
		String algorithm = "SHA-512"
	)
	{
		var encoding = "UTF-8";
		var hashed = hash( arguments.password & arguments.salt, arguments.algorithm, encoding );

		for ( var i = 1; i <= iterations; i++ )
		{
			hashed = hash( hashed & salt, arguments.algorithm, encoding );
		}

		return hashed;
	}

	public any function genSalt
	(
		Numeric size = 16, //How many bytes should be used to generate the salt
		String type = "base64" //Should be either binary or base64
	)
	{
		switch( arguments.type )
		{
			case "binary": case "bin":
				return genBinarySalt( arguments.size );
				break;
			default:
				return genBase64Salt( arguments.size );
				break;
		}
	}

	private String function genBase64Salt
	(
		required Numeric size
	)
	{
		return toBase64( genBinarySalt( arguments.size ) );
	}

	/*
	 * Thanks to Christian Cantrell!!
	 * http://weblogs.macromedia.com/cantrell/archives/2004/01/byte_arrays_and_1.html
	 **/
	private Binary function genBinarySalt
	(
		required Numeric size
	)
	{
		var byteType = createObject( "java", "java.lang.Byte" ).TYPE;
		var bytes = createObject( "java", "java.lang.reflect.Array" ).newInstance( byteType, arguments.size );
		var rand = createObject( "java", "java.security.SecureRandom" ).nextBytes( bytes );

		return bytes;
	}
}

