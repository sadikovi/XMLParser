XMLParser
=========

Very simple XML parser for working with REST API.

Creates NSDictionary from received XML object.
You can see the example of implementation in "Parser" folder.
Creates NSDictionary with root key XML_TAG_MAIN.

Example like this:

    <a>
      <b type="text">
        <ba>SampleText</ba>
        <bb>AnotherSampleText</bb>
      </b>
      <c>
      </c>
    </a>
  

will be converted to NSDictionary like this:

    {
        "ISXMLPARSER_MAIN" = "ISXMLPARSER_MAIN";
        "ISXMLPARSER_ENTITIES" = ({
            "ISXMLPARSER_QUALIFIED_NAME" = a;
            "ISXMLPARSER_ENTITIES" = ({
                "ISXMLPARSER_QUALIFIED_NAME" = b;
                type = "text";
                "ISXMLPARSER_ENTITIES" = ({
                    "ISXMLPARSER_QUALIFIED_NAME" = ba;
                    "ISXMLPARSER_ELEMENT_TEXT" = "SampleText"
                    "ISXMLPARSER_ENTITIES" = ();
                }, {
                    "ISXMLPARSER_QUALIFIED_NAME" = bb;
                    "ISXMLPARSER_ELEMENT_TEXT" = "AnotherSampleText"
                    "ISXMLPARSER_ENTITIES" = ();
                });
            }, {
                "ISXMLPARSER_QUALIFIED_NAME" = c;
                "ISXMLPARSER_ENTITIES" = ();
            });
        });
    }

Where
  
    ISXMLPARSER_QUALIFIED_NAME - tag name (full, with namespaceURI, e.g. "ID" or "XMLPS:PHOTO")
  
    ISXMLPARSER_ELEMENT_TEXT - tag's text (12345 for <id>12345</id>)
  
    ISXMLPARSER_ENTITIES - child nodes represented as NSArray
  
    all attributes of tag will be included in element object like ("type" = "text")
  

You can change them in ISXMLParser.h, anyway


Initialisation
==============

Add files "ISXMLParser.h" and "ISXMLParser.m" to the project.

Instantiate ISXMLParser as a parser with NSData received, calling:

    ISXMLParser *parser = [[ISXMLParser alloc] initWithData:data];
    parser.delegate = self;


Protocol ISXMLParserDelegate
============================
All delegate methods are required:
    
    XMLParser just started parsing data
    - (void)parserDidStartParsingData:(ISXMLParser *)parser;
  
    XMLParser finished parsing data with result available
    - (void)parser:(ISXMLParser *)parser didFinishParsingWithResult:(NSDictionary *)result;
  
    XMLParser failed with error while parsing
    - (void)parser:(ISXMLParser *)parser didFailWithError:(NSError *)error;
  

Start parcing
=============

For start parcing just call (parser is an instance of ISXMLParser):
  
    [parser startParsing];
  

Cancel parsing
==============

To cancel parsing call:
    
    [parser cancelParsing];
  
  
