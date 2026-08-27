Class AIHubStudio.Tool.DataAccess Extends %AI.Tool
{

/// List resources explicitly exposed by this read-only toolkit.
Method ListDataResources() As %DynamicObject [ WebMethod ]
{
    Set sc = ##class(AIHubStudio.Metadata.ToolAudit).Log("ListDataResources","{}",$$$OK,2)
    Quit {"sql":["AIHubStudio_Data.SampleCustomer"],"globals":["^AIHubStudio.Sample"],"readOnly":true,"maxRows":50,"maxDepth":3}
}

/// Find allowlisted sample customers by optional name prefix. Maximum 50 rows.
Method FindCustomers(name As %String = "", limit As %Integer = 20) As %DynamicObject [ WebMethod ]
{
    If limit < 1 Set limit = 1
    If limit > 50 Set limit = 50
    Set rows = [], result = {"rows":(rows),"row_count":0,"truncated":false}
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT TOP ? ID,Name,City,Segment FROM AIHubStudio_Data.SampleCustomer WHERE (? = '' OR Name %STARTSWITH ?) ORDER BY Name")
    If $$$ISERR(sc) {
        Set audit = ##class(AIHubStudio.Metadata.ToolAudit).Log("FindCustomers",{"name":(name),"limit":(limit)}.%ToJSON(),sc)
        Do result.%Set("error",$SYSTEM.Status.GetErrorText(sc))
        Quit result
    }
    Set rs = stmt.%Execute(limit,name,name)
    While rs.%Next() {
        Do rows.%Push({"id":(rs.ID),"name":(rs.Name),"city":(rs.City),"segment":(rs.Segment)})
    }
    Do result.%Set("row_count",rows.%Size())
    Set audit = ##class(AIHubStudio.Metadata.ToolAudit).Log("FindCustomers",{"name":(name),"limit":(limit)}.%ToJSON(),$$$OK,rows.%Size())
    Quit result
}

/// Read bounded nodes from allowlisted ^AIHubStudio.Sample global only.
Method ReadSampleGlobal(path As %String = "^AIHubStudio.Sample", depth As %Integer = 2, limit As %Integer = 20) As %DynamicObject [ WebMethod ]
{
    Set rows = [], result = {"rows":(rows),"count":0,"truncated":false}
    If path '= "^AIHubStudio.Sample" {
        Set denied = $$$ERROR($$$AICoreToolAccessDenied,"Global path is not allowlisted")
        Set audit = ##class(AIHubStudio.Metadata.ToolAudit).Log("ReadSampleGlobal",{"path":(path)}.%ToJSON(),denied)
        Quit {"error":"Global path is not allowlisted"}
    }
    If depth < 0 Set depth = 0
    If depth > 3 Set depth = 3
    If limit < 1 Set limit = 1
    If limit > 50 Set limit = 50
    Set root = "^AIHubStudio.Sample", reference = root, current = $QUERY(@reference)
    While (current '= "") && ($EXTRACT(current,1,$LENGTH(root)) = root) && (rows.%Size() < limit) {
        Set subscriptCount = $QLENGTH(current)
        If subscriptCount <= depth Do rows.%Push({"reference":(current),"value":($GET(@current))})
        Set current = $QUERY(@current)
    }
    Do result.%Set("count",rows.%Size())
    If (current '= "") && ($EXTRACT(current,1,$LENGTH(root)) = root) Do result.%Set("truncated",true)
    Set audit = ##class(AIHubStudio.Metadata.ToolAudit).Log("ReadSampleGlobal",{"path":(path),"depth":(depth),"limit":(limit)}.%ToJSON(),$$$OK,rows.%Size())
    Quit result
}

}
