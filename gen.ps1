param (
  [string]$build_type
)

function ConfigProject($vcxprojFile) {
  # Adjust the path to be the relative of the vcxproj file
  $vcxprojFile = Split-Path -Path $vcxprojFile -Leaf
  $vcxprojFile = Join-Path -Path $PSScriptRoot -ChildPath $vcxprojFile

  # Conan setup
  $conan = @"
  <ImportGroup Label="PropertySheets" Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'">
    <Import Project="`$(UserRootDir)\Microsoft.Cpp.`$(Platform).user.props" Condition="exists('`$(UserRootDir)\Microsoft.Cpp.`$(Platform).user.props')" Label="LocalAppDataPlatform" />
    <Import Project=".\build\Release\x64\.conan\conanbuildinfo.props" />
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'`$(Configuration)|`$(Platform)'=='Debug|x64'">
    <Import Project="`$(UserRootDir)\Microsoft.Cpp.`$(Platform).user.props" Condition="exists('`$(UserRootDir)\Microsoft.Cpp.`$(Platform).user.props')" Label="LocalAppDataPlatform" />
    <Import Project=".\build\Debug\x64\.conan\conanbuildinfo.props" />
  </ImportGroup>
"@

  # ClangTidy support
  $clangTidy = @"
    <EnableMicrosoftCodeAnalysis>false</EnableMicrosoftCodeAnalysis>
    <EnableClangTidyCodeAnalysis>true</EnableClangTidyCodeAnalysis>
"@

  $releaseProperty = @"
<PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'">
"@

  $debugProperty = @"
<PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|x64'">
"@

  $newFileContent = ""
  $file = [System.IO.StreamReader]::new($vcxprojFile)
  while (!$file.EndOfStream) {
    $line = $file.ReadLine()

    # 1) Check if it's time to write conan setup
    if ($line.TrimStart() -eq '<ImportGroup Label="ExtensionSettings">') {
      $temp = $line
      $line = $file.ReadLine()
      $temp = "$temp`n$line"
      $line = "$temp`n$conan"
    }
    
    # 2) Check if it's time to enable ClangTidy
    if (($line.TrimStart() -eq $releaseProperty) -or ($line.TrimStart() -eq $debugProperty)) {
      $line = "$line`n$clangTidy"
    }

    # Check if need to add a new line character
    if (!$file.EndOfStream) {
      $newFileContent = "$newFileContent$line`n"
    }
    else {
      $newFileContent = "$newFileContent$line"
    }
  }
  $file.Close()
  Set-Content -Path $vcxprojFile -Value $newFileContent
}

if ($build_type -eq "") {
  Write-Host "Build type not specified."
  exit 1
}

$build_type = $build_type.ToLower()
$build_type = $build_type.Substring(0, 1).ToUpper() + $build_type.Substring(1)
if (($build_type -ne "Debug") -and ($build_type -ne "Release")) {
  Write-Host "Build type not supported. Possible values: [Debug, Release]."
  exit 1
}

Write-Host "Build type: $build_type"
Invoke-Expression "conan install . --install-folder=.\build\$build_type\x64\.conan --build missing --profile:build default -s build_type=$build_type"
Invoke-Expression "premake5 vs2019"
ConfigProject ".\AppTemplate.vcxproj"
ConfigProject ".\Tests.vcxproj"