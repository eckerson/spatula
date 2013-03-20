component
	implements="spatula.interfaces.Parser"
	extends="spatula.TextParser"
{

	public String function parseText(
		required String unformattedText
	)
	{
		var formattedText = "";
		var unformattedTextArray = listToArray( arguments.unformattedText, chr( 10 ), true );
		var formattedTextArray = [];
		var listFindRegex = "^[\*##;:]";
		var listReplaceRegex = "^([\*##;:]+)([\s\w\W\S]+)";
		var currentLine = "";
		var previousLine = "";
		var currentList = [];
		var previousList = [];
		var listLevelDifference = 0;
		var listLevelStartIndex = 0;
		var isBlock = false;
		var theText = "";
		var useFormatting = true;

//writeDump( unformattedTextArray );
		for ( var i = 1; i <= arrayLen( unformattedTextArray ); i++ )
		{
			theText = unformattedTextArray[ i ];

			if ( reFindNoCase( "^<pre", trim( theText ), 1, false ) )
			{
				//Start of a preformatted block
				useFormatting = false;
			}

			if ( useFormatting == true )
			{
				//Handle block formatting
				theText = parse_blockFormatting( theText );

				//Handle link formatting
				theText = parse_linkFormatting( theText );

				isBlock = isBlockTag( theText );

				//Determine what block formatting to use for the line
				previousLine = currentLine;
				if ( reFind( listFindRegex, unformattedTextArray[ i ] ) )
				{
					previousList = currentList;
					currentList = listToArray( reReplace( theText, listReplaceRegex, "\1" ), "" );

					currentLine = "li";
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

				if ( currentLine == "li" )
				{
					if ( previousLine != "li" &&
						previousLine != "" )
					{
						arrayAppend( formattedTextArray, "</" & previousLine & ">" );
					}

					if ( arrayLen( previousList ) == 0 )
					{
						arrayAppend(
								formattedTextArray,
								incrementListLevel( currentList, 1 )
							);
					}
					else if ( arrayLen( previousList ) > 0 )
					{
						//Determine if the depth should change
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
									decrementListLevel( previousList, arrayLen( currentList ) )
								);
							
							arrayAppend(
									formattedTextArray,
									"</" & getListItemType( previousList[ arrayLen( currentList ) ] ) & ">"
								);

							arrayAppend(
									formattedTextArray,
									"<" & getListItemType( currentList[ arrayLen( currentList ) ] ) & ">"
								);
						}
						else
						{
							arrayAppend(
									formattedTextArray,
									"</" & getListItemType( previousList[ arrayLen( previousList ) ] ) & ">"
								);

							arrayAppend(
									formattedTextArray,
									"<" & getListItemType( currentList[ arrayLen( currentList ) ] ) & ">"
								);
						}
					}
					

					arrayAppend(
							formattedTextArray,
							parse_inlineFormatting( reReplace( theText, listReplaceRegex, "\2" ) )
						);
				}
				else
				{
					if ( currentLine != previousLine )
					{
						if ( previousLine == "li" )
						{
							previousList = currentList;
							currentList = [];

							arrayAppend(
								formattedTextArray,
								decrementListLevel( previousList, 0 )
							);

							previousList = [];
						}
						else if ( previousLine != "" )
						{
							arrayAppend( formattedTextArray, "</" & previousLine & ">" );
						}

						if ( currentLine != "" )
						{
							arrayAppend( formattedTextArray, "<" & currentLine & ">" );
						}
					}

					arrayAppend( formattedTextArray, parse_inlineFormatting( theText ) );
				}
			}
			else
			{
				arrayAppend( formattedTextArray, theText );
			}

			if ( reFindNoCase( "<\/pre", trim( theText ), 1, false ) )
			{
				useFormatting = true;
			}
		}

		if ( currentLine == "li" )
		{
			arrayAppend(
					formattedTextArray,
					decrementListLevel( currentList, 0 )
				);
		}
		else if ( currentLine != "" )
		{
			arrayAppend( formattedTextArray, "</" & currentLine & ">" );
		}
//writeDump( formattedTextArray );
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

			case ";": case ":":
				listType = "dl";
				break;
		}

		return listType;
	}

	private String function getListItemType( required String maskCharacter )
	{
		var listItemType = "";

		switch( arguments.maskCharacter )
		{
			case ";":
				listItemType = "dt";
				break;

			case ":":
				listItemType = "dd";
				break;

			default:
				listItemType = "li";
				break;
		}

		return listItemType;
	}

	private String function incrementListLevel(
		required Array listArray,
		required Numeric startIndex
	)
	{
		var listString = "";
		var listType = "";
		var listItemType = "";

		for ( var i = arguments.startIndex; i <= arrayLen( arguments.listArray ); i++ )
		{
			listType = getListType( arguments.listArray[ i ] );
			listItemType = getListItemType( arguments.listArray[ i ] );

			/*if ( i != 1 )
			{
				listString &= "<li>";
			}*/

			listString &= "<" & listType & "><" & listItemType & ">";
		}

		return listString;
	}

	private String function decrementListLevel(
		required Array listArray,
		required Numeric endIndex
	)
	{
		var listString = "";
		var listType = "";
		var listITemType = "";

		for ( var i = arrayLen( arguments.listArray ); i > arguments.endIndex; i-- )
		{
			listType = getListType( arguments.listArray[ i ] );		
			listItemType = getListItemType( arguments.listArray[ i ] )	;
			listString &= "</" & listItemType & "></" & listType & ">";

			/*if ( i != 1 )
			{
				listString &= "</li>";
			}*/
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
		formattedText = parse_externalLinks( formattedText );

		return formattedText;
	}

	private String function parse_internalLinks(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;
		var controllerStyle = variables.controllerStyle;
		var defaultController = variables.defaultController;
		var defaultView = variables.defaultView;
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

			//Format the link to conform to the controller style
			var formattedLinkPage = "";
			var linkPageArray = listToArray( linkPage, ":", true );

			switch ( controllerStyle )
			{
				case "wiki":
					formattedLinkPage = linkPage;
					break;

				default:
					if ( arrayLen( linkPageArray ) == 1 )
					{
						formattedLinkPage = defaultController & "/" & linkPageArray[ 1 ];
					}
					else if ( arrayLen( linkPageArray ) > 1 &&
						len( trim( linkPageArray[ 2 ] ) ) )
					{
						formattedLinkPage = linkPageArray[ 1 ] & "/" & linkPageArray[ 2 ];
					}
					else
					{
						formattedLinkPage = linkPageArray[ 1 ] & "/" & defaultView;
					}
					break;
			}

			//Make page for link URL-safe (replace spaces with underscores)
			formattedLinkPage = replace( formattedLinkPage, " ", "_", "all" );

			//Append word ending if approperiate
			if ( len( trim( wordEnding ) ) &&
				!reFindNoCase( "^<nowiki", wordEnding, 1, false ) )
			{
				linkLabel &= wordEnding;
			}

			//Build the HTML link
			htmlLink = '<a href="/Index.cfm/' & formattedLinkPage & '" class="internal-link">' & linkLabel & '</a>';

			formattedText = replace( formattedText, wikiLink, htmlLink );
		}

		if ( reFindNoCase( pattern, formattedText, 0, false ) )
		{
			//Another link exists in the string, parse it
			formattedText = parse_internalLinks( formattedText );
		}

		return formattedText;
	}

	private String function parse_externalLinks(
		required String unformattedText
	)
	{
		var formattedText = arguments.unformattedText;
		var bracketPattern = "\[((http://|https://)[\w\-\.]+)(\?[\w\=\%\&]+)?( [\S ]+)?\]";
		var mailtoPattern = "\[((mailto:)[\w\.\!\##\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+@[\w\-\.]+)(\?[\w\=\%\&]+)?( [\S ]+)?\]";
		var simplePattern = "((http://|https://)[\w\-\.]+)(\?[\w\=\%\&]+)?";
		var wikiLink = "";
		var uri = "";
		var queryString = "";
		var label = "";
		var foundBracketLink = reFindNoCase( bracketPattern, formattedText, 0, true );
		var foundMailtoLink = reFindNoCase( mailtoPattern, formattedText, 0, true );
		var foundSimpleLink = reFindNoCase( simplePattern, formattedText, 0, true );
		var htmlLink = "";

		if ( foundBracketLink.pos[ 1 ] > 0 )
		{
			/*
			 * Parse bracket pattern
			 *
			 * Position 1 is the wiki link
			 * Position 2 is the uri
			 * Position 3 is the protocol
			 * Position 4 is the query string
			 * Position 5 is label with leading space (trim before use)
			 */
			wikiLink = mid( formattedText, foundBracketLink.pos[ 1 ], foundBracketLink.len[ 1 ] );
			uri = mid( formattedText, foundBracketLink.pos[ 2 ], foundBracketLink.len[ 2 ] );

			if ( foundBracketLink.pos[ 4 ] > 0 )
			{
				queryString = mid( formattedText, foundBracketLink.pos[ 4 ], foundBracketLink.len[ 4 ] );
			}

			if ( foundBracketLink.pos[ 5 ] > 0 )
			{
				label = mid( formattedText, foundBracketLink.pos[ 5 ], foundBracketLink.len[ 5 ] );
			}
		}
		else if ( foundMailtoLink.pos[ 1 ] > 0 )
		{
			/*
			 * Parse mailto links
			 *
			 * Position 1 is the wiki link
			 * Position 2 is the uri
			 * Position 3 is the protocol
			 * Position 4 is the query string
			 * Position 5 is label with leading space (trim before use)
			 */
			wikiLink = mid( formattedText, foundMailtoLink.pos[ 1 ], foundMailtoLink.len[ 1 ] );
			uri = mid( formattedText, foundMailtoLink.pos[ 2 ], foundMailtoLink.len[ 2 ] );

			if ( foundMailtoLink.pos[ 4 ] > 0 )
			{
				queryString = mid( formattedText, foundMailtoLink.pos[ 4 ], foundMailtoLink.len[ 4 ] );
			}

			if ( foundMailtoLink.pos[ 5 ] > 0 )
			{
				label = mid( formattedText, foundMailtoLink.pos[ 5 ], foundMailtoLink.len[ 5 ] );
			}
		}
		else if ( foundSimpleLink.pos[ 1 ] > 0 )
		{
			/*
			 * Parse simple links
			 *
			 * Position 1 is the wiki link
			 * Position 2 is the uri
			 * Position 3 is the protocol
			 * Position 4 is the query string
			 */
			wikiLink = mid( formattedText, foundSimpleLink.pos[ 1 ], foundSimpleLink.len[ 1 ] );
			uri = mid( formattedText, foundSimpleLink.pos[ 2 ], foundSimpleLink.len[ 2 ] );

			if ( foundSimpleLink.pos[ 4 ] > 0 )
			{
				queryString = mid( formattedText, foundSimpleLink.pos[ 4 ], foundSimpleLink.len[ 4 ] );
			}
		}

		uri = trim( uri );
		queryString = trim( queryString );
		label = trim( label );

		if ( len( uri ) )
		{
			if ( !len( label ) )
			{
				label = uri;
			}

			//Build the HTML link
			htmlLink = '<a href="' & uri & queryString & '" class="external-link">' & label & '</a>';

			formattedText = replace( formattedText, wikiLink, htmlLink );
		}

		if ( reFindNoCase( bracketPattern, formattedText, 0, false ) )
		{
			//Another link exists in the string, parse it
			formattedText = parse_externalLinks( formattedText );
		}

		return formattedText;
	}

}