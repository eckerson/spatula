<!--- Param required arguments --->
<cfparam name="arguments.Exception" />
<cfparam name="arguments.EventName" />

<cfthrow object="#arguments.Exception#" />