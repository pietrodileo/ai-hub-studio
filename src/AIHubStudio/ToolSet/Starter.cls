Class AIHubStudio.ToolSet.Starter Extends %AI.ToolSet [ DependsOn = (AIHubStudio.Tool.Starter, AIHubStudio.Tool.DataAccess) ]
{

XData Definition [ MimeType = application/xml ]
{
<ToolSet Name="StudioStarter">
  <Description>Read-only sample customer data and calculator tools.</Description>
  <Include Class="AIHubStudio.Tool.Starter" />
  <Include Class="AIHubStudio.Tool.DataAccess" />
</ToolSet>
}

}
