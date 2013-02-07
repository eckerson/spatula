component
	extends = "spatula.Framework"
{
	/*
	 * Application Settings
	 */
	this.name = "spatulaFramework";
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan( 0, 0, 1, 0 );
	this.clientManagement = false;
	//this.datasource = "";
	this.loginStorage = "session";
	this.serverSideFormValidation = false;
	this.setClientCookies = true;
	this.setDomainCookies = true;
}