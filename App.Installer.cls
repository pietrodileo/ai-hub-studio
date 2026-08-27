Class App.Installer
{
// Manifest class to install the source code and configure the environment
XData setup
{
<Manifest>
  <Log Level="3" Text="Start manifest" />
  <Log Level="3" Text="Working directory: #{$system.Process.CurrentDirectory()}" />

  <!-- Define Manifest Variables -->
  <Default Name="NAMESPACE" Value="AI_HUB_STUDIO"/>
  <Default Name="DBNAME" Value="AI_HUB_STUDIO"/>
  <Default Name="APPPATH" Dir="/usr/irissys/mgr/"/>
  <Default Name="SOURCESPATH" Dir="/home/irisowner/dev/src" />
  <!-- <Default Name="SourceDir" Value="#{$system.Process.CurrentDirectory()}src"/> -->
  <Default Name="RESOURCE" Value="%DB_${DBNAME}" /> 
  
  <!-- Import source code into existing namespace -->
  <Log Level="3" Text="Importing source code into namespace ${NAMESPACE}" />
  <Namespace Name="${NAMESPACE}">
    <Import File="${SOURCESPATH}" Recurse="1"/>
  </Namespace>

  <!-- Create Web Application to reach the production -->
  <Invoke Class="App.Installer" Method="RegisterWebApplication" CheckStatus="1" Return="restsc"> 
    <Arg Value="${NAMESPACE}"/>
    <Arg Value="/ai-hub/api/studio"/>
    <Arg Value="AIHubStudio.REST.WebGateway"/>
    <Arg Value="REST API to handle messages"/>
    <Arg Value="1"/>
  </Invoke>

  <Invoke Class="App.Installer" Method="RegisterMCPApplication" CheckStatus="1" Return="mcpsc">
    <Arg Value="${NAMESPACE}"/>
    <Arg Value="/mcp/data"/>
    <Arg Value="AIHubStudio.MCP.DataService"/>
  </Invoke>

  <Namespace Name="${NAMESPACE}">
    <Invoke Class="AIHubStudio.Setup" Method="Run" CheckStatus="1" Return="setupsc"/>
  </Namespace>

  <Log Level="3" Text="End manifest" />

</Manifest>
}

ClassMethod RegisterMCPApplication(pNameSpace As %String, pName As %String, pClassName As %String) As %Status
{
    New $Namespace
    Set $Namespace = "%SYS"
    If '##class(Security.Roles).Exists("AIHubStudioMCP") {
        Set resources = "%DB_"_pNameSpace_"_CODE:R,%DB_"_pNameSpace_"_DATA:RW"
        Set sc = ##class(Security.Roles).Create("AIHubStudioMCP","Least-privilege role for audited AI Hub Studio MCP access",resources,"")
        If $$$ISERR(sc) Quit sc
    }
    Set spec("AutheEnabled") = $$$AuthePassword
    Set spec("NameSpace") = pNameSpace
    Set spec("Description") = "Read-only audited IRIS data MCP endpoint"
    Set spec("IsNameSpaceDefault") = $$$NO
    Set spec("DispatchClass") = pClassName
    Set spec("MatchRoles") = ":AIHubStudioMCP"
    If '##class(Security.Applications).Exists(pName) {
        Set sc = ##class(Security.Applications).Create(pName,.spec)
    } Else {
        Set sc = ##class(Security.Applications).Modify(pName,.spec)
    }
    Quit sc
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

/// Create a web application with a specified path and dispatch class in the desired namespace
ClassMethod RegisterWebApplication(pNameSpace As %String = "NAMESPACENAME", pName As %String = "/wspath", pClassName As %String = "AIHubStudio.REST.WebGateway", pDescription As %String = "REST API to handle messages", verbose As %Boolean = 0) As %Status
{
    New $Namespace
    Set $Namespace = "%SYS"
    Set ret = $$$OK
    Set spec("AutheEnabled") = $$$AutheUnauthenticated
    Set spec("NameSpace") = pNameSpace
    Set spec("Description") = pDescription
    Set spec("IsNameSpaceDefault") = $$$NO
    Set spec("DispatchClass") = pClassName
    Set spec("MatchRoles")=":%All"

    If ('##class(Security.Applications).Exists(pName)) {
        If verbose Write !,"Creating Web application """_pName_"""..."
        Set ret = ##class(Security.Applications).Create(pName, .spec)
        If verbose Write !, "Web application """_pName_""" is created.",!
    }
    Else { // ensure configuration matches in case of updating from old terminal versions
        If verbose Write !, "Updating web application """_pName_"""..."
        Set ret = ##class(Security.Applications).Modify(pName, .spec)
        If verbose Write !, "Web application """_pName_""" is updated.",!
    }
    Return ret
}

}
