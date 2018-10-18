
function Get-TestFromAst {
    param(
        $ast
    )

    $eb = $ast.EndBlock
    foreach($statement in $eb.Statements) {
        if ($statement -isnot 'System.Management.Automation.Language.PipelineAst') {
            continue
        }
        $commandAst = $statement.PipelineElements[0].CommandElements[0]

        if ($commandAst.Value -eq 'Describe') {
            Get-TestName $commandAst
        }
    }
}
