Class AIHubStudio.Data.SampleCustomer Extends %Persistent
{

Property Name As %String(MAXLEN = 100) [ Required ];
Property City As %String(MAXLEN = 100);
Property Segment As %String(MAXLEN = 40);

ClassMethod Seed() As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT COUNT(*) AS ItemCount FROM AIHubStudio_Data.SampleCustomer")
    If $$$ISERR(sc) Quit sc
    Set rs = stmt.%Execute()
    If rs.%Next(), rs.ItemCount > 0 Quit $$$OK
    Set sc = $$$OK
    For row="Ada Lovelace|London|Enterprise","Grace Hopper|New York|Public","Edsger Dijkstra|Rotterdam|Research" {
        Set item = ..%New()
        Set item.Name = $PIECE(row,"|",1), item.City = $PIECE(row,"|",2), item.Segment = $PIECE(row,"|",3)
        Set sc = item.%Save()
        If $$$ISERR(sc) Quit
    }
    Set ^AIHubStudio.Sample("company","name") = "InterSystems demo"
    Set ^AIHubStudio.Sample("company","region") = "Europe"
    Set ^AIHubStudio.Sample("metrics","activeCustomers") = 3
    Quit sc
}

Storage Default
{
<Data name="SampleCustomerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>City</Value>
</Value>
<Value name="4">
<Value>Segment</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio750.SampleCustomerD</DataLocation>
<DefaultData>SampleCustomerDefaultData</DefaultData>
<IdLocation>^AIHubStudio750.SampleCustomerD</IdLocation>
<IndexLocation>^AIHubStudio750.SampleCustomerI</IndexLocation>
<StreamLocation>^AIHubStudio750.SampleCustomerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
