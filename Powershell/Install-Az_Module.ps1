<# Set the execution policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned

try {
    # Setting PSRepository as Trusted
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

    Write-Output "[+] Installing Nuget Provider"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        
    # Checking whether Az Module is already present in the Hybrid Worker Virtual Machine or not
    $InstalledModule = Get-InstalledModule Az*
    echo $InstalledModule
        
    if (-not (Get-Module -ListAvailable -Name Az.*)) {
        # Installng Az Module into the Hybrid Worker Virtual Machine
        Write-Output "[+] Installing Az Modules"
        Install-Module -Name Az -Force -AllowClobber
        Get-Module -Name Az.* -ListAvailable
        
    } 
    else{
        Write-Output "[+] Az Modules are already installed"        
    }    
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}#>

# Ensure the NuGet provider is installed
try{

if (-not (Get-PackageProvider -ListAvailable -Name NuGet)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Write-Output "NuGet provider installed successfully."
} else {
    Write-Output "NuGet provider is already installed."
}
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}

try {
# Install the Az module
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -AllowClobber -Force
    Write-Output "Az module installed successfully."
} else {
    Write-Output "Az module is already installed."
}
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}

try{
# Import the Az module
Import-Module Az
Write-Output "Az module imported successfully."
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}
 


