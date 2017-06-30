
function Get-TestFromAst {
    param(
        $ast
    )

    $eb = $ast.EndBlock
    foreach($statement in $eb.Statements)
    {
        if ( $statement -isnot "System.Management.Automation.Language.PipelineAst" )
        {
            continue
        }
        $CommandAst = $statement.PipelineElements[0].CommandElements[0]

        if (  $CommandAst.Value -eq "Describe" )
        {
            Get-TestName $CommandAst
        }
    }
}
