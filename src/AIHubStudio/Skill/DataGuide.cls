Class AIHubStudio.Skill.DataGuide Extends %AI.Agent.Skill
{

XData SUMMARY [ MimeType = "text/yaml" ]
{
name: iris-data-guide
description: Inspect allowlisted sample IRIS data and explain findings safely.
parameters:
  - name: userRequest
    description: Data question to investigate.
    type: string
    required: true
tags:
  - iris
  - data
}

XData INSTRUCTIONS [ MimeType = "text/markdown" ]
{
Use only allowlisted read-only tools. State when results are truncated. Never infer access to resources not returned by ListDataResources.
}

}
