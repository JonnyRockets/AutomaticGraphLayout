$path = Split-Path $MyInvocation.MyCommand.path

function DoGraph {
    param(
        [Parameter(ValueFromPipeline=$true)]
        $data,
        [Parameter(Position=0)]
        $map=@('source','target'),
        [ValidateSet('MdsLayoutSettings','SugiyamaLayoutSettings')]
        $layoutSettings="MdsLayoutSettings"
    )

    begin {
        Add-Type -Path "$path\Microsoft.Msagl.dll"
        Add-Type -Path "$path\Microsoft.Msagl.Drawing.dll"
        Add-Type -Path "$path\Microsoft.Msagl.GraphViewerGdi.dll"
        Add-Type -AssemblyName System.Windows.Forms
    
        $form = New-Object system.Windows.Forms.Form

        $viewer = New-Object Microsoft.Msagl.GraphViewerGdi.GViewer
        $graph = New-Object Microsoft.Msagl.Drawing.Graph("graph")
    }

    process {
        $null=$graph.AddEdge($data.($map[0]),$data.($map[1]))
    }
    

    end {

        switch ($layoutSettings) {
            'SugiyamaLayoutSettings' {$settings = New-Object Microsoft.Msagl.Layout.Layered.SugiyamaLayoutSettings}
            'MdsLayoutSettings' {$settings = New-Object Microsoft.Msagl.Layout.MDS.MdsLayoutSettings}
        }        
                
        $graph.LayoutAlgorithmSettings = $settings
        $viewer.CurrentLayoutMethod=[Microsoft.Msagl.GraphViewerGdi.LayoutMethod]::UseSettingsOfTheGraph 
        $viewer.Graph = $graph

        $form.SuspendLayout()

        $form.ClientSize = New-Object System.Drawing.Size 800, 700
        
        $viewer.Dock = [System.Windows.Forms.DockStyle]::Fill
        $form.Controls.Add($viewer)
        $form.ResumeLayout() 
        $form.StartPosition = "CenterScreen"
        
        $null=$form.ShowDialog()
    }
}