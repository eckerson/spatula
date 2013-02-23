spatula
=======

A simple ColdFusion MVC framework.
The purpose of this framework is to allow the application to serve up content with the following features:

* Application configuration storage and retreival.
* Object caching and retreival.
* Support for markup parsing for views.


Things to Do
------------
* Review the folder structure used by the object library service.
* Review setting organization (use sub-objects or split into separate configs).
* Add markup parsing support.
* * Add wiki markup support.
* * Look into additional markup support (markdown?).
* Add additional error handling with view templates (onError, onMissingTemplate, Missing View CFM, etcetera).
* Change the object caching service to auto-load from a root folder (with the first folder being the library name).


MVC
---
There are currently two supported styles for making requests (determined by the _CONTROLLER_STYLE_ config setting):

* *wiki*

	The address is formatted like so: "/controller:view/parameters?query_string".
	For example, "website.com/Index.cfm/main:home" will load the _main_ controller and the _home_ view.
	If only one item is specified for the controller or view, it's assumed to be the view.
	For example, if the URL is "website.com/Index.cfm/foo", the application will assume the default controller and use the _foo_ view.
	This is done to be consistent with standard wiki URL parsing.

* *default*

	The address is formatted like so: "/controller/view/parameters?query_string".
	For example, "website.com/Index.cfm/main/home" will load the _main_ controller and the _home_ view.
	If only one item is specified for the controller or view, it's assumed to be the controller.
	For example, if the URL is "website.com/Index.cfm/foo", the application will use the _foo_ controller and assume the default view.
	This is done to be consistent with standard MVC URL parsing.

The default controller and view to use when one or both are not specified are determined by the _DEFAULT_CONTROLLER_ and _DEFAULT_VIEW_ config settings.

* The request controller determines the controller object and the view folder.
* The request view determines the controller function and the view file.
* Variables returned from the controller function are merged into the VARIABLES scope for the view.

If the Struct returned by the controller function contains a "title" or a "template" variable, it will override the default settings for the page title or template.

* By default, the page title is the name of the View.
* By default, the application uses the "Default" template.

The currently used controller is stored in _request.controller_.
Likewise, the currently used view is stored in _request.view_.

If the controller component does not contain a function named after the requested view, the framework will fire the onMissingControllerFunction handler to load a view to handle the error.  The template loaded can be found in "/lib/template/error/MissingControllerFunction.cfm". The onMissingControllerFunction function can be overridden in the controller object to perform custom functionality (such as loading user-defined content from a database).


Parameters
----------
The parameters found in the path info are merged with the URL and FORM variables scopes.
The merged parameters are stsored in _request.parameters_.
The parameters found in the path info are slash-delimited (/) and are formatted like so: "key:value".
When merging the URL and FORM scopes into request.parameters; the URL scope overwrites any duplicate parameters and the FORM scope overwrites any duplicate URL variables and parameters.


Configuration
-------------
Configuration files are stored in the "/lib/config" directory.
The files are formatted in JSON, with a *.json file extension.
The application will auto-load any JSON file in that directory.
To reference a config setting, call "config.get( _setting_, _config (optional)_ )".
By default, "config.get()" will reference the "Application" config (so you only need to specify a config if you are reading from an alternative config file).
The name of the config is determined by the file name (for example, settings in the foo.json config can be referenced by calling "config.get( _setting_, "foo" )").


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

* *lazyLoad*

	Determines if the object should be cached when it's first requested ("true") or on application-start ("false"). The default for this setting is determined by the _DEFAULT_LAZY_LOAD_ setting.

Objects can be retreived either by using "spatula.get( _libraryName_, _classpath_ )", or by calling the object factory directly in memory (for example, "application.services.get( _classpath_ )").
Using "spatula" is preferred, since it will hunt for the appropriate variable scope for you.


Resetting the Application and Session Variable Scopes
-----------------------------------------------------
The application variable scope can be reset by passing "resetApplication=true" in the query string.
The session variable scope can be reset by passing "resetSession=true" in the query string.