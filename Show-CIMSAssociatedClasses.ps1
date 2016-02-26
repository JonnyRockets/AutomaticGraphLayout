. .\AutoGraph.ps1

function Get-AssociatedClassRelationship {
    param (
        [String]
        $Namespace = 'root/cimv2'
    )

    Get-CimClass -Namespace $Namespace | ? { $_.CimClassQualifiers['Association'] -and (-not $_.CimClassQualifiers['Abstract']) } | % {
        $KeyQualifiers = @($_.CimClassProperties | ? { $_.Qualifiers['key'] })

        if ($KeyQualifiers.Count -eq 2) {
            [PSCustomObject][Ordered] @{
                AssociationClassName = $_.CimClassName
                LinkedClassName1 = $KeyQualifiers[0].ReferenceClassName
                LinkedClassName2 = $KeyQualifiers[1].ReferenceClassName
            }            
        }
    }
}

Get-AssociatedClassRelationship | foreach {
    [psobject]@{source=$_.LinkedClassName1;target=$_.AssociationClassName}
    [psobject]@{source=$_.AssociationClassName;target=$_.LinkedClassName2}
} | DoGraph -layoutSettings MdsLayoutSettings
