component
	implements="spatula.interfaces.Parser"
{

	public String function parseText(
		required String unformattedText
	)
	{
		var formattedText = "";
		var unformattedTextArray = listToArray( arguments.unformattedText, chr( 10 ), true );
		var formattedTextArray = [];
		var listFindRegex = "^[\*##]";
		var listReplaceRegex = "^([\*##]+)([\s\w\W\S]+)";
		var currentLine = "";
		var previousLine = "";
		var currentTag = "";
		var previousTag = "";
		var currentList = [];
		var previousList = [];
		var listLevelDifference = 0;
		var listLevelStartIndex = 0;
		var isBlock = false;
		var theText = "";

//writeDump( unformattedTextArray );
		for ( var i = 1; i <= arrayLen( unformattedTextArray ); i++ )
		{
			theText = unformattedTextArray[ i ];

			//Handle block formatting
			theText = parse_blockFormatting( theText );

			//Handle link formatting
			theText = parse_linkFormatting( theText );

			isBlock = isBlockTag( theText );

			//Determine what block formatting to use for the line
			previousLine = currentLine;
			if ( reFind( listFindRegex, unformattedTextArray[ i ] ) )
			{
				currentLine = "li";
				previousList = currentList;
				currentList = listToArray( reReplace( theText, listReplaceRegex, "\1" ), "" );
			}
			else if ( unformattedTextArray[ i ] == "" )
			{
				currentLine = "";
			}
			else if ( !isBlock )
			{
				currentLine = "p";
			}
			else
			{
				currentLine = "";
			}

			if ( currentLine != previousLine )
			{
				if ( previousLine == "li" )
				{
					previousTag = getListType( previousList[ arrayLen( previousList ) ] );

					currentList = [];

					arrayAppend(
								formattedTextArray,
								decrementListLevel( previousList, arrayLen( previousList ) )
							);
				}
				else
				{
					previousTag = previousLine;
				}
				
				if ( currentLine == "li" )
				{
					currentTag = getListType( currentList[ arrayLen( currentList ) ] );
				}
				else
				{
					currentTag = currentLine;
				}

				if ( previousLine != "" )
				{
					arrayAppend( formattedTextArray, "</" & previousTag & ">" );
				}

				if ( currentLine != "" )
				{
					arrayAppend( formattedTextArray, "<" & currentTag & ">" );
				}
			}

			if ( currentLine == "li" )
			{
				//Determine if the depth should change
				if ( arrayLen( previousList ) > 0 )
				{
					listLevelDifference = arrayLen( currentList ) - arrayLen( previousList );
					listLevelStartIndex = arrayLen( previousList );

					if ( listLevelDifference > 0 )
					{
						//Go deeper
						arrayAppend(
								formattedTextArray,
								incrementListLevel( currentList, listLevelStartIndex + 1 )
							);
					}
					else if ( listLevelDifference < 0 )
					{
						//Go shallower
						arrayAppend(
								formattedTextArray,
								decrementListLevel( previousList, listLevelStartIndex )
							);
					}
				}

				arrayAppend(
						formattedTextArray,
						"<li>" & parse_inlineFormatting( reReplace( theText, listReplaceRegex, "\2" ) ) & "</li>"
					);
			}
			else
			{
				arrayAppend( formattedTextArray, parse_inlineFormatting( theText ) );
			}
		}

		arrayAppend( formattedTextArray, "</" & currentLine & ">" );

		formattedText = arrayToList( formattedTextArray, chr( 10 ) );
		return formattedText;
	}

	private Boolean function isBlockTag(
		required String thisLine
	)
	{
		var isBlockTag = false;
		var blockTags = [
			"h",
			"table",
			"tr",
			"td",
			"th",
			"tbody",
			"thead",
			"tfoot",
			"col",
			"colgroup",
			"div",
			"pre",
			"ul",
			"ol",
			"li",
			"dt",
			"dd",
			"!--"
		];
		var pattern = 0;

		for ( var i = 1; i <= arrayLen( blockTags ); i++ )
		{
			pattern = "^<\/{0,1}" & blockTags[ i ];

			if ( reFindNoCase( pattern, trim( arguments.thisLine ), 1, false ) )
			{
				isBlockTag = true;
				break;
			}
		}

		return isBlockTag;
	}

	private String function getListType( required String maskCharacter )
	{
		var listType = "";

		switch( arguments.maskCharacter )
		{
			case "*":
				listType = "ul";
				break;

			case "##":
				listType = "ol";
				break;
		}

		return listType;
	}

	private String function incrementListLevel(
		required Array listArray,
		required Numeric startIndex
	)
	{
		var listString = "";

		for ( var i = arguments.startIndex; i <= arrayLen( arguments.listArray ); i++ )
		{
			listString &= "<li>";

			switch( arguments.listArray[ i ] )
			{
				case "*":
					listString &= "<ul>";
					break;

				case "##":
					listString &= "<ol>";
			}
		}

		return listString;
	}

	private String function decrementListLevel(
		required Array listArray,
		required Numeric endIndex
	)
	{
		var listString = "";

		for ( var i = arrayLen( arguments.listArray ); i >= arguments.endIndex; i-- )
		{
			switch( arguments.listArray[ i ] )
			{
				case "*":
					listString &= "</ul>";
					break;

				case "##":
					listString &= "</ol>";
			}
			
			listString &= "</li>";
		}

		return listString;
	}

	/*
	#### ##    ## ##       #### ##    ## ########                                              
	 ##  ###   ## ##        ##  ###   ## ##                                                    
	 ##  ####  ## ##        ##  ####  ## ##                                                    
	 ##  ## ## ## ##        ##  ## ## ## ######                                                
	 ##  ##  #### ##        ##  ##  #### ##                                                    
	 ##  ##   ### ##        ##  ##   ### ##                                                    
	#### ##    ## ######## #### ##    ## ########                                              
	########  #######  ########  ##     ##    ###    ######## ######## #### ##    ##  ######   
	##       ##     ## ##     ## ###   ###   ## ##      ##       ##     ##  ###   ## ##    ##  
	##       ##     ## ##     ## #### ####  ##   ##     ##       ##     ##  ####  ## ##        
	######   ##     ## ########  ## ### ## ##     ##    ##       ##     ##  ## ## ## ##   #### 
	##       ##     ## ##   ##   ##     ## #########    ##       ##     ##  ##  #### ##    ##  
	##       ##     ## ##    ##  ##     ## ##     ##    ##       ##     ##  ##   ### ##    ##  
	##        #######  ##     ## ##     ## ##     ##    ##       ##    #### ##    ##  ######   
	*/
	public String function parse_inlineFormatting(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;

		formattedText = parse_strong( formattedText );
		formattedText = parse_emphasis( formattedText );

		return formattedText;
	}

	private String function parse_strong(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;
		var strongCharacter = "*";
		var pattern = "\" & strongCharacter & "(.*?)\" & strongCharacter;

		formattedText = reReplace( formattedText, pattern, "<strong>\1</strong>", "all" );

		return formattedText;
	}

	private String function parse_emphasis(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;
		var emphasisCharacter = "_";
		var pattern = emphasisCharacter & "(.*?)" & emphasisCharacter;

		formattedText = reReplace( formattedText, pattern, "<em>\1</em>", "all" );

		return formattedText;
	}

	/*
	########  ##        #######   ######  ##    ##                                             
	##     ## ##       ##     ## ##    ## ##   ##                                              
	##     ## ##       ##     ## ##       ##  ##                                               
	########  ##       ##     ## ##       #####                                                
	##     ## ##       ##     ## ##       ##  ##                                               
	##     ## ##       ##     ## ##    ## ##   ##                                              
	########  ########  #######   ######  ##    ##                                             
	########  #######  ########  ##     ##    ###    ######## ######## #### ##    ##  ######   
	##       ##     ## ##     ## ###   ###   ## ##      ##       ##     ##  ###   ## ##    ##  
	##       ##     ## ##     ## #### ####  ##   ##     ##       ##     ##  ####  ## ##        
	######   ##     ## ########  ## ### ## ##     ##    ##       ##     ##  ## ## ## ##   #### 
	##       ##     ## ##   ##   ##     ## #########    ##       ##     ##  ##  #### ##    ##  
	##       ##     ## ##    ##  ##     ## ##     ##    ##       ##     ##  ##   ### ##    ##  
	##        #######  ##     ## ##     ## ##     ##    ##       ##    #### ##    ##  ######   
	*/
	public String function parse_blockFormatting(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;

		formattedText = parse_headings( formattedText );
		formattedText = parse_horizontalRule( formattedText );

		return formattedText;
	}

	private String function parse_headings(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;
		var headingCharacter = "=";
		var pattern = 0;
		var foundHeadings = 0;

		for ( var i = 6; i >= 2; i-- )
		{
			pattern = "^" & headingCharacter & "{" & i & "}(.*?)" & headingCharacter & "{" & i & "}";

			//Find occurances of header
			foundHeadings = reMatch( pattern, formattedText );

			formattedText = reReplace( formattedText, pattern, "<h" & i & ">\1</h" & i & ">", "all" );
		}

		return formattedText;
	}

	private String function parse_horizontalRule(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;
		var horizontalRuleCharacter = "-";
		var pattern = "^" & horizontalRuleCharacter & "{4}";

		formattedText = reReplace( formattedText, pattern, "<hr />", "all" );

		return formattedText;
	}

	/*
	##       #### ##    ## ##    ##                                                            
	##        ##  ###   ## ##   ##                                                             
	##        ##  ####  ## ##  ##                                                              
	##        ##  ## ## ## #####                                                               
	##        ##  ##  #### ##  ##                                                              
	##        ##  ##   ### ##   ##                                                             
	######## #### ##    ## ##    ##                                                            
	########  #######  ########  ##     ##    ###    ######## ######## #### ##    ##  ######   
	##       ##     ## ##     ## ###   ###   ## ##      ##       ##     ##  ###   ## ##    ##  
	##       ##     ## ##     ## #### ####  ##   ##     ##       ##     ##  ####  ## ##        
	######   ##     ## ########  ## ### ## ##     ##    ##       ##     ##  ## ## ## ##   #### 
	##       ##     ## ##   ##   ##     ## #########    ##       ##     ##  ##  #### ##    ##  
	##       ##     ## ##    ##  ##     ## ##     ##    ##       ##     ##  ##   ### ##    ##  
	##        #######  ##     ## ##     ## ##     ##    ##       ##    #### ##    ##  ######   
	*/
	public String function parse_LinkFormatting(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;

		formattedText = parse_internalLinks( formattedText );

		return formattedText;
	}

	private String function parse_internalLinks(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;
		var pattern = "\[\[(.*?)\]\]((?:<nowiki(?: ){0,1}(?:\/){0,1}>)|[\w]*)";
		var wikiLink = "";
		var wikiLinkText = "";
		var wordEnding = "";
		var linkPage = "";
		var linkLabel = "";
		var foundLink = reFindNoCase( pattern, formattedText, 0, true );
		var htmlLink = "";

		/*
		 * Position 1 is full link
		 * Position 2 is inner text
		 * Position 3 is word ending
		 */

		if ( foundLink.pos[ 1 ] )
		{
			wikiLink = mid( formattedText, foundLink.pos[ 1 ], foundLink.len[ 1 ] );
		}

		if ( arrayLen( foundLink.pos ) > 1 &&
			foundLink.pos[ 2 ] )
		{
			wikiLinkText = mid( formattedText, foundLink.pos[ 2 ], foundLink.len[ 2 ] );
		}

		if ( arrayLen( foundLink.pos ) > 2 &&
			foundLink.pos[ 3 ] )
		{
			wordEnding = mid( formattedText, foundLink.pos[ 3 ], foundLink.len[ 3 ] );
		}

		if ( len( trim( wikiLink ) ) )
		{
			var textArray = listToArray( wikiLinkText, "|", true );

			if ( arrayLen( textArray ) == 1 )
			{
				linkPage = textArray[ 1 ];
				linkLabel = textArray[ 1 ];
			}
			else if ( arrayLen( textArray ) > 1 )
			{
				linkPage = textArray[ 1 ];
				linkLabel = textArray[ 2 ];

				if ( len( trim( linkLabel ) ) == 0 )
				{
					//Hide namespace if shown
					var labelArray = listToArray( linkPage, ":", true );

					if ( arrayLen( labelArray ) == 1 )
					{
						linkLabel = labelArray[ 1 ];
					}
					else if ( arrayLen( labelArray ) > 1 )
					{
						linkLabel = labelArray[ 2 ];
					}
				}
			}

			//Make page for link URL-safe (replace spaces with underscores)
			linkPage = replace( linkPage, " ", "_", "all" );

			//Append word ending if approperiate
			if ( len( trim( wordEnding ) ) &&
				!reFindNoCase( "^<nowiki", wordEnding, 1, false ) )
			{
				linkLabel &= wordEnding;
			}

			//Build the HTML link
			htmlLink = '<a href="/Index.cfm/' & linkPage & '">' & linkLabel & '</a>';

			formattedText = replace( formattedText, wikiLink, htmlLink );
		}

		if ( reFindNoCase( pattern, formattedText, 0, false ) )
		{
			//Another link exists in the string, parse it
			formattedText = parse_internalLinks( formattedText );
		}

		return formattedText;
	}

}