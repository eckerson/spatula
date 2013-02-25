component
	extends="spatula.Service"
	accessors=true
{
	public ControllerService function init()
	{
		return this;
	}

	public spatula.beans.View function generateView(
		required String controller,
		required String view
	)
	{
		var controllerObject = createObject( "component", "lib.controller." & arguments.controller );
		var viewData = controllerObject.renderView( argumentCollection = arguments );

		return viewData;
	}
}