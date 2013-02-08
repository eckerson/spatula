spatula
=======

A simple ColdFusion MVC framework.


Things to Do
------------
* Object Lazy-Loading.
* Review the folder structure used by the object library service.
* Add the option to parse wiki formatting automatically.
* Add the ability for the service response to appropriately set the HTTP response codes based on its status.


Request Process
---------------
1. Request points to "/Index.cfm/ControllerName/ViewName"
2. Application calls "lib.controller.ControllerName:ViewName()" controller function.
3. The controller function makes any service calls to handle any business logic for the request
4. The application loads the "/lib/view/controllername/ViewName.cfm" to handle the view display.


Request Parsing
---------------
A utility object is called to parse the request variables.

The URL and FORM scopes are merged together into a "request.parameters" Struct.

* Any key found in both the URL and FORM scopes will use the one in the FORM scope (So a form variable can temporarily overwrite a URL variable for the post).

PathInfo is a slash-delimited list of request parameters.

* The first two items in PathInfo are the controller and view (in that order).
* * The request controller is stored in "request.controller".
* * The request view is stored in "request.view".
* Any additional items in PathInfo are colon-delimited lists of variables and values (for example, variable:value). These are appended into the request parameters.


MVC Structure
-------------
A service object handles loading the view for the request based on what is in "request.controller" and "request.view".

* The request controller determines the controller object and the view folder.
* The request view determines the controller function and the view file.
* Variables returned from the controller function are merged into the VARIABLES scope for the view.

If the Struct returned by the controller function contains a "title" or a "template" variable, it will override the default settings for the page title or template.

* By default, the page title is the name of the View.
* By default, the application uses the "Default" template.


Object Caching
--------------
Any object found in either "/lib/com/model" or "/lib/com/service" will automatically be loaded into an appropriate ObjectFactory and cached in memory.
How the object is loaded can be configured as an attribute on the component.

* *scope*

	The memory scope to cache the object into. Available scopes are: application (default), session, and request.

* *dependencies*

	A comma-delimited list of additional objects that are required to be loaded prior to loading the current one (for example, "Foo,bar.Jazz").

* *constructorArgs*

	A comma-delimited list of constructor arguments and their values. Arguments and values are colon-delimited (for example, "arg1:value1,arg2:value2").

Objects can be retreived either by using "spatula.get( libraryName, classpath )", or by calling the object factory directly in memory (for example, "application.services.get( classpath )").
Using "spatula" is preferred, since it will hunt for the appropriate variable scope for you.


Resetting the Application and Session Variable Scopes
-----------------------------------------------------
The application variable scope can be reset by passing "resetApplication=true" in the query string.
The session variable scope can be reset by passing "resetSession=true" in the query string.