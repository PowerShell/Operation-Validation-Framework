
function Get-TestName {
    param(
        $ast
    )

    for($i = 1; $i -lt $ast.Parent.CommandElements.Count; $i++) {
        if ($ast.Parent.CommandElements[$i] -is 'System.Management.Automation.Language.CommandParameterAst') {
            $i++; continue
        }
        if ($ast.Parent.CommandElements[$i] -is 'System.Management.Automation.Language.ScriptBlockExpressionAst') {
            continue
        }
        if ($ast.Parent.CommandElements[$i] -is 'System.Management.Automation.Language.StringConstantExpressionAst') {
            return $ast.Parent.CommandElements[$i].Value
        }
    }

    throw 'Could not determine test name'
}
