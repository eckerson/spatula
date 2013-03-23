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
					

					theText = reReplace( theText, listReplaceRegex, "\2" );
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
				}

				//Handle formatting the line of text
				theText = parse_line( theText );
			}

			arrayAppend( formattedTextArray, theText );

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

	private String function parse_line(
		required String unformattedText
	)
	{
		var formattedText = "";
		var fullNoWikiRegex = "";
		var openNoWikiRegex = "<nowiki>";
		var closeNoWikiRegex = "</nowiki>";
		var selfNoWikiRegex = "<nowiki ?/>";
		var noWikiRegex = "</?nowiki ?/?>";
		var foundFullNoWiki = "";
		var foundOpenNoWiki = reFindNoCase( openNoWikiRegex, arguments.unformattedText, 1, true );
		var foundCloseNoWiki = reFindNoCase( closeNoWikiRegex, arguments.unformattedText, 1, true );

		//writeDump( foundOpenNoWiki );

		var foundNoWiki = 0;
		var allFoundNoWikis = [];
		var i = 1;
		var textArray = [];
		var textStart = 1;
		var textLength = 0;
		var canFormat = true;
		var foundSelfNoWiki = 0;

		while ( reFindNoCase( noWikiRegex, arguments.unformattedText, i, false ) > 0 )
		{
			foundNoWiki = reFindNoCase( noWikiRegex, arguments.unformattedText, i, true );

			arrayAppend(
					allFoundNoWikis,
					{
						"tag" = mid( arguments.unformattedText, foundNoWiki.pos[ 1 ], foundNoWiki.len[ 1 ] ),
						"pos" = foundNoWiki.pos[ 1 ],
						"len" = foundNoWiki.len[ 1 ],
						"tag_type" = ""
					}
				);

			if ( reFindNoCase( openNoWikiRegex, allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tag" ], 1, false ) > 0 )
			{
				//Tag is an open tag
				allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tag_type" ] = "open";
			}
			else if ( reFindNoCase( closeNoWikiRegex, allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tag" ], 1, false ) > 0 )
			{
				//Tag is a close tag
				allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tag_type" ] = "close";
			}
			else if ( reFindNoCase( selfNoWikiRegex, allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tag" ], 1, false ) > 0 )
			{
				//Tag is a self tag
				allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tag_type" ] = "self";
			}

			//allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tagType" ]

			i = foundNoWiki.pos[ 1 ] + foundNoWiki.len[ 1 ];
		}

		if ( arrayLen( allFoundNoWikis ) )
		{
			for ( i = 1; i <= arrayLen( allFoundNoWikis ); i++ )
			{
				textLength = allFoundNoWikis[ i ].pos - textStart;

				if ( i == 1 )
				{
					switch ( allFoundNoWikis[ i ][ "tag_type" ] )
					{
						case "open": case "self":
							canFormat = true;
							break;
						
						case "close":
							canFormat = false;
							break;
					}
				}
				else
				{
					switch ( allFoundNoWikis[ i - 1 ][ "tag_type" ] )
					{
						case "open":
							canFormat = false;
							break;
						
						case "close":
							canFormat = true;
							break;

						case "self":
							foundSelfNoWiki = reFindNoCase( "([^\s]+)", arguments.unformattedText, textStart, true );

							if ( foundSelfNoWiki.pos[ 1 ] > 0 )
							{
								textLength = foundSelfNoWiki.len[ 1 ];

								arrayAppend(
										textArray,
										{
											"canFormat" = false,
											"text" = mid( arguments.unformattedText, textStart, textLength )
										}
									);

								textStart += textLength;
								textLength = allFoundNoWikis[ i ].pos - textStart;
							}

							doFormat = true;
							break;
					}
				}

				arrayAppend(
						textArray,
						{
							"canFormat" = canFormat,
							"text" = mid( arguments.unformattedText, textStart, textLength )
						}
					);

				textStart += textLength + allFoundNoWikis[ i ].len;
			}

			if ( textStart <= len( arguments.unformattedText ) )
			{
				textLength = len( arguments.unformattedText ) - textStart + 1;

				switch ( allFoundNoWikis[ arrayLen( allFoundNoWikis ) ][ "tag_type" ] )
				{
					case "open":
						canFormat = false;
						break;
					
					case "close":
						canFormat = true;
						break;

					case "self":
						foundSelfNoWiki = reFindNoCase( "([^\s]+)", arguments.unformattedText, textStart, true );

						if ( foundSelfNoWiki.pos[ 1 ] > 0 )
						{
							textLength = foundSelfNoWiki.len[ 1 ];

							arrayAppend(
									textArray,
									{
										"canFormat" = false,
										"text" = mid( arguments.unformattedText, textStart, textLength )
									}
								);

							textStart += textLength;
							textLength = len( arguments.unformattedText ) - textStart + 1;
						}
						doFormat = true;
						break;
				}

				arrayAppend(
						textArray,
						{
							"canFormat" = canFormat,
							"text" = mid( arguments.unformattedText, textStart, textLength )
						}
					);

			}
		}
		else
		{
			arrayAppend(
					textArray,
					{
						"canFormat" = true,
						"text" = arguments.unformattedText
					}
				);
		}

		for ( i = 1; i <= arrayLen( textArray ); i++ )
		{
			if ( textArray[ i ].canFormat )
			{
				//Handle link formatting
				textArray[ i ].text = parse_linkFormatting( textArray[ i ].text );

				//Handle inline formatting
				textArray[ i ].text = parse_inlineFormatting( textArray[ i ].text );
			}

			formattedText &= textArray[ i ].text;
		}

		return formattedText;
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
		var bracketPattern = "\[((http://|https://)[\w\-\.]+)([\/\w\-\.]+)?(\?[\w\=\%\&]+)?( [\S ]+)?\]";
		var mailtoPattern = "\[((mailto:)[\w\.\!\##\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+@[\w\-\.]+)(\?[\w\=\%\&]+)?( [\S ]+)?\]";
		var simplePattern = "((http://|https://)[\w\-\.]+)([\/\w\-\.]+)?(\?[\w\=\%\&]+)?";
		var wikiLink = "";
		var uri = "";
		var folderStructure = "";
		var queryString = "";
		var label = "";
		var foundBracketLink = reFindNoCase( bracketPattern, formattedText, 0, true );
		var foundMailtoLink = reFindNoCase( mailtoPattern, formattedText, 0, true );
		var foundSimpleLink = reFindNoCase( simplePattern, formattedText, 0, true );
		var htmlLink = "";

		if ( foundBracketLink.pos[ 1 ] > 0 )
		{
			writeDump(foundBracketLink);
			/*
			 * Parse bracket pattern
			 *
			 * Position 1 is the wiki link
			 * Position 2 is the uri
			 * Position 3 is the protocol
			 * Position 4 is the folder structure
			 * Position 5 is the query string
			 * Position 6 is label with leading space (trim before use)
			 */
			wikiLink = mid( formattedText, foundBracketLink.pos[ 1 ], foundBracketLink.len[ 1 ] );
			uri = mid( formattedText, foundBracketLink.pos[ 2 ], foundBracketLink.len[ 2 ] );

			if ( foundBracketLink.pos[ 4 ] > 0 )
			{
				folderStructure = mid( formattedText, foundBracketLink.pos[ 4 ], foundBracketLink.len[ 4 ] );
			}

			if ( foundBracketLink.pos[ 5 ] > 0 )
			{
				queryString = mid( formattedText, foundBracketLink.pos[ 5 ], foundBracketLink.len[ 5 ] );
			}

			if ( foundBracketLink.pos[ 6 ] > 0 )
			{
				label = mid( formattedText, foundBracketLink.pos[ 6 ], foundBracketLink.len[ 6 ] );
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
			 * Position 4 is the folder structure
			 * Position 5 is the query string
			 */
			wikiLink = mid( formattedText, foundSimpleLink.pos[ 1 ], foundSimpleLink.len[ 1 ] );
			uri = mid( formattedText, foundSimpleLink.pos[ 2 ], foundSimpleLink.len[ 2 ] );

			if ( foundSimpleLink.pos[ 4 ] > 0 )
			{
				folderStructure = mid( formattedText, foundSimpleLink.pos[ 4 ], foundSimpleLink.len[ 4 ] );
			}

			if ( foundSimpleLink.pos[ 5 ] > 0 )
			{
				queryString = mid( formattedText, foundSimpleLink.pos[ 5 ], foundSimpleLink.len[ 5 ] );
			}
		}

		uri = trim( uri );
		folderStructure = trim( folderStructure );
		queryString = trim( queryString );
		label = trim( label );

		if ( len( uri ) )
		{
			if ( !len( label ) )
			{
				label = uri & folderStructure;
			}

			//Build the HTML link
			htmlLink = '<a href="' & uri & folderStructure & queryString & '" class="external-link">' & label & '</a>';

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