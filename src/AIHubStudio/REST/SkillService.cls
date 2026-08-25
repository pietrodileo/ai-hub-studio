/// Class: AIHubStudio.REST.SkillService
/// Description: REST API for Skill Management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.REST.SkillService Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

/// Method: ListSkills
/// Description: List all registered skills
ClassMethod ListSkills() As %Status
{
    set sc = $$$OK
    try {
        set skills = ##class(AIHubStudio.Skill.Registry).List()
        write skills
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: GetSkill
/// Description: Get skill details by ID
ClassMethod GetSkill(id As %String) As %Status
{
    set sc = $$$OK
    try {
        set skill = ##class(AIHubStudio.Skill.Registry).Get(id)
        write skill
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: RegisterSkill
/// Description: Register a new skill
ClassMethod RegisterSkill(name As %String, description As %String, className As %String, skillType As %String = "knowledge") As %Status
{
    set sc = $$$OK
    try {
        set skillId = ##class(AIHubStudio.Skill.Registry).Register(name, description, className, skillType)
        write {"skillId": (skillId), "status": ($SELECT(skillId'="": "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: UpdateSkill
/// Description: Update skill details
ClassMethod UpdateSkill(id As %String, name As %String, description As %String, className As %String, skillType As %String) As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Skill.Registry).Update(id, name, description, className, skillType)
        write {"skillId": (id), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: DeleteSkill
/// Description: Delete a skill
ClassMethod DeleteSkill(id As %String) As %Status
{
    set sc = $$$OK
    try {
        set status = ##class(AIHubStudio.Skill.Registry).Delete(id)
        write {"skillId": (id), "status": ($SELECT(status: "success", 1: "failed"))}
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

/// Method: SearchSkills
/// Description: Search skills by name pattern
ClassMethod SearchSkills(pattern As %String) As %Status
{
    set sc = $$$OK
    try {
        set skills = ##class(AIHubStudio.Skill.Registry).Search(pattern)
        write skills
    } catch ex {
        Set sc = ex.AsStatus()
        write "error: "_$SYSTEM.Status.GetErrorText(sc)
    }
    Return sc
}

}
