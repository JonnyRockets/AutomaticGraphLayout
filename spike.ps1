$path = Split-Path $MyInvocation.MyCommand.path

Add-Type -Path "$path\Microsoft.Msagl.dll"
Add-Type -Path "$path\Microsoft.Msagl.Drawing.dll"
Add-Type -Path "$path\Microsoft.Msagl.GraphViewerGdi.dll"
Add-Type -AssemblyName System.Windows.Forms

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

$form = New-Object system.Windows.Forms.Form

$viewer = New-Object Microsoft.Msagl.GraphViewerGdi.GViewer
$graph = New-Object Microsoft.Msagl.Drawing.Graph("graph")

Get-AssociatedClassRelationship | % {
    $null=$graph.AddEdge($_.LinkedClassName1, $_.AssociationClassName)
    $null=$graph.AddEdge($_.AssociationClassName, $_.LinkedClassName2)
} 

$viewer.Graph = $graph

$form.SuspendLayout()
$viewer.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($viewer)
$form.ResumeLayout() 
$form.StartPosition = "CenterScreen"
        
$form.ShowDialog()