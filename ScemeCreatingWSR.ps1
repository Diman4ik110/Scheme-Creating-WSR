Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form

#Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore

########################
# Variables
########################
$Global:Stands = @()
$Global:VMTypes = @()
$Global:OSTypes = @()
$Global:Adapters = @()
$Global:AdapterList = @()
[Int32]$Position = 0
$Global:VMLocation = 30
$Global:VMCount = 1
$Global:CreateCounter
#######################
# Functions
#######################
 
function Add-VMForStand {
    param (
        [int]$Count,
        [int]$Location,
        [System.Windows.Forms.Panel]$Container
    )
    #Creating Object
    [System.Windows.Forms.ComboBox]$VMType = New-Object System.Windows.Forms.ComboBox
    [System.Windows.Forms.ComboBox]$OSType = New-Object System.Windows.Forms.ComboBox
    [System.Windows.Forms.ComboBox]$NetAdapter = New-Object System.Windows.Forms.ComboBox
    [System.Windows.Forms.Button]$NewButton = New-Object System.Windows.Forms.Button
    [System.Windows.Forms.TextBox]$VMName = New-Object System.Windows.Forms.TextBox

    $Container.Controls.Add($NewButton)
    $Container.Controls.Add($ServerIP)
    $Container.Controls.Add($NetAdapter)
    $Container.Controls.Add($VMName)
    $Container.Controls.Add($VMType)
    $Container.Controls.Add($OSType)
    $Global:VMLocation = $Global:VMLocation + 25
    
    if ($Global:VMLocation -gt $MainBox.Height) {
        $MainBox.Height += 25
        $form.Height += 25
        $CreateButton.Top += 25
    }

    # VM Name Settings
    $VMName.Width = 120
    $VMName.Location = New-Object System.Drawing.Point(30, $Location)
    # New Button Settings
    $NewButton.Add_Click({ ButtonClick })
    $NewButton.Text = "+"
    $NewButton.Width = 20
    $NewButton.Height = 20
    $NewButton.Location = New-Object System.Drawing.Point(5, $Location)

    # Type Select Box Setting
    $VMType.Width = 80
    $VMType.Items.Add("Debian")
    $VMType.Items.Add("Cent OS 8")
    $VMType.Items.Add("Windows Server 2019")
    $VMType.Items.Add("Windows 10")
    $VMType.Location = New-Object System.Drawing.Point(160, $Location)

    $OSType.Width = 80
    $OSType.Items.Add("GUI")
    $OSType.Items.Add("Console")
    $OSType.Location = New-Object System.Drawing.Point(250, $Location)

    
    $NetAdapter.Width = 100
    $NetAdapter.Location = New-Object System.Drawing.Point(340, $Location)
    
    $Global:Adapters += $NetAdapter
    $Global:VMTypes += $VMType
    $Global:OSTypes += $OSType

    Update-AdapterList
}

########################
# Creating elements
########################

[System.Windows.Forms.Label]$ConnectStatusLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$ConnectIPLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$ConnectStatus = New-Object System.Windows.Forms.Label

[System.Windows.Forms.Label]$RAMSettingLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$HDDSettingLabel = New-Object System.Windows.Forms.Label

# Linux OS Settings
[System.Windows.Forms.Label]$LinuxSettingLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.TextBox]$LinuxRAMSettingText = New-Object System.Windows.Forms.TextBox
[System.Windows.Forms.TextBox]$LinuxHDDSettingText = New-Object System.Windows.Forms.TextBox

# Windows OS Setting
[System.Windows.Forms.Label]$WindowsSettingLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.TextBox]$WindowsRAMSettingText = New-Object System.Windows.Forms.TextBox
[System.Windows.Forms.TextBox]$WindowsHDDSettingText = New-Object System.Windows.Forms.TextBox

# vCenter IP address
[System.Windows.Forms.Label]$vSphereLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.TextBox]$vSphereIP = New-Object System.Windows.Forms.TextBox
[System.Windows.Forms.Button]$NetList = New-Object System.Windows.Forms.Button
# Main Box
[System.Windows.Forms.Panel]$MainBox = New-Object System.Windows.Forms.Panel

[System.Windows.Forms.Label]$VMNameLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$VMTypeLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$OSTypeLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$Adapter = New-Object System.Windows.Forms.Label

[System.Windows.Forms.Button]$CreateButton = New-Object System.Windows.Forms.Button

#########################
# Element Events
#########################
function Create() {
    if ($ConnectStatus.Text -eq "Connected") {
        
    }else {
        [System.Windows.Forms.MessageBox]::Show("Connect to ESXI Server first!","Warning")
    }
}
function Get_NetList() {
    if ($vSphereIP.Text -eq "") {
        return
    }else {
        $tmp = Connect-VIServer -Server $vSphereIP.Text
        for ($i = 0; $i -lt (Get-VirtualPortGroup).Name.Count; $i++) {
            $Global:AdapterList += (Get-VirtualPortGroup)[$i].Name
        }
        Update-AdapterList
        if ($tmp.IsConnected) {
            $ConnectStatus.ForeColor = "Green"
            $ConnectStatus.Text = "Connected"
            $ConnectIPLabel.Text = $tmp.Name
        }
    }
}
function Update-AdapterList {
    for ($i = 0; $i -lt $Global:Adapters.Count; $i++) {
        for ($j = 0; $j -lt $Global:AdapterList.Count; $j++) {
            $Global:Adapters[$i].Items.Add($Global:AdapterList[$j])
        }
    }
}
function ButtonClick () {
    $Global:VMCount = $Global:VMCount + 1
    Add-VMForStand -Count $Global:VMCount -Location $Global:VMLocation -Container $MainBox
}

##########################
# Element Description
##########################

$form.Height = 350
$form.Width = 500
$form.Text = "Creating VM Script"
$form.add_FormClosing({
    param($sender,$e)
    if ($ConnectStatusLabel.Text -eq "Connected") {
        Disconnect-VIServer $ConnectIPLabel.Text -Confirm -Force
    }
})
$form.StartPosition = "CenterScreen"

$Position += 10
$ConnectStatusLabel.Width = 100
$ConnectStatusLabel.Text = "Connection status: "
$ConnectStatusLabel.Location = New-Object System.Drawing.Point(110, $Position)

$ConnectStatus.Width = 80
$ConnectStatus.Text = "not connected"
$ConnectStatus.ForeColor = "Red"
$ConnectStatus.Location = New-Object System.Drawing.Point(220, $Position)

$ConnectIPLabel.Width = 80
$ConnectIPLabel.Text = "N/A"
$ConnectIPLabel.Location = New-Object System.Drawing.Point(300, $Position)

$Position += 25
$RAMSettingLabel.Width = 55
$RAMSettingLabel.Text = "RAM, Gb"
$RAMSettingLabel.Location = New-Object System.Drawing.Point(110, $Position)

$HDDSettingLabel.Width = 60
$HDDSettingLabel.Text = "HDD, Gb"
$HDDSettingLabel.Location = New-Object System.Drawing.Point(165, $Position)

$Position += 25
$LinuxSettingLabel.Width = 80
$LinuxSettingLabel.Text = "Linux Settings"
$LinuxSettingLabel.Location = New-Object System.Drawing.Point(20, $Position)

$LinuxRAMSettingText.Width = 30
$LinuxRAMSettingText.Location = New-Object System.Drawing.Point(120, $Position)

$LinuxHDDSettingText.Width = 30
$LinuxHDDSettingText.Location = New-Object System.Drawing.Point(175, $Position)

$Position += 30
$WindowsSettingLabel.Width = 100
$WindowsSettingLabel.Text = "Windows Settings"
$WindowsSettingLabel.Location = New-Object System.Drawing.Point(20, $Position)

$WindowsRAMSettingText.Width = 30
$WindowsRAMSettingText.Location = New-Object System.Drawing.Point(120, $Position)

$WindowsHDDSettingText.Width = 30
$WindowsHDDSettingText.Location = New-Object System.Drawing.Point(175, $Position)

$Position += 30
$vSphereLabel.Width = 150
$vSphereLabel.Text = "Server IP"
$vSphereLabel.Location = New-Object System.Drawing.Point(20, $Position)

$vSphereIP.Width = 150
$vSphereIP.Location = New-Object System.Drawing.Point(120, $Position)

$NetList.Width = 80
$NetList.Height = 20
$NetList.Text = "Connect"
$NetList.Add_Click({Get_NetList})
$NetList.Location = New-Object System.Drawing.Point(280, $Position)

# Main Box
$Position += 40
$MainBox.Width = 445
$MainBox.Height = 85
$MainBox.Location = New-Object System.Drawing.Point(20, $Position)
$MainBox.BorderStyle = 1

$MainBox.Controls.Add($OSNameLabel)
$MainBox.Controls.Add($VMNameLabel)
$MainBox.Controls.Add($CompleteStatusLabel)

$VMNameLabel.Width = 120
$VMNameLabel.Text = "VM Name"
$VMNameLabel.Location = New-Object System.Drawing.Point(65, 5)
$MainBox.Controls.Add($VMNameLabel)

$VMTypeLabel.Width = 50
$VMTypeLabel.Text = "OS"
$VMTypeLabel.Location = New-Object System.Drawing.Point(190, 5)
$MainBox.Controls.Add($VMTypeLabel)

$OSTypeLabel.Width = 50
$OSTypeLabel.Text = "OS Type"
$OSTypeLabel.Location = New-Object System.Drawing.Point(265, 5)
$MainBox.Controls.Add($OSTypeLabel)

$Adapter.Width = 50
$Adapter.Text = "Adapter"
$Adapter.Location = New-Object System.Drawing.Point(370, 5)
$MainBox.Controls.Add($Adapter)


Add-VMForStand -Count $Global:VMCount -Location $Global:VMLocation -Container $MainBox

$Position += 110
$CreateButton.Location = New-Object System.Drawing.Point(190, $Position)
$CreateButton.Width = 100
$CreateButton.Height = 30
$CreateButton.Text = "Create"
$CreateButton.Add_Click({ Create })

###########################
# Adding element to Form
###########################

$form.Controls.Add($ConnectStatusLabel)
$form.Controls.Add($ConnectStatus)
$form.Controls.Add($ConnectIPLabel)

$form.Controls.Add($RAMSettingLabel)
$form.Controls.Add($HDDSettingLabel)

$form.Controls.Add($LinuxSettingLabel)
$form.Controls.Add($LinuxRAMSettingText)
$form.Controls.Add($LinuxHDDSettingText)

$form.Controls.Add($WindowsSettingLabel)
$form.Controls.Add($WindowsRAMSettingText)
$form.Controls.Add($WindowsHDDSettingText)

$form.Controls.Add($vSphereIP)
$form.Controls.Add($vSphereLabel)
$form.Controls.Add($NetList)
$form.Controls.Add($MainBox)
$form.Controls.Add($CreateButton)
$form.ShowDialog()