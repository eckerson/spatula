component
	extends="Base"
{
	variables.controllerStyle = config.get( "MVC.CONTROLLER_STYLE", "Framework" );
	variables.defaultController = config.get( "MVC.DEFAULT_CONTROLLER", "Framework" );
	variables.defaultView = config.get( "MVC.DEFAULT_VIEW", "Framework" );
}