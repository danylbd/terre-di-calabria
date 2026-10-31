; Terre di Calabria — wizard di installazione (Inno Setup 6.3 o successivo)
; Compilazione:  ISCC.exe /DAppVersion=0.0.1 installer\setup.iss
; Prima vanno esportati i giochi in build\arm64 e build\x64 (vedi .github/workflows/build.yml).

#define AppName "Terre di Calabria"
#define AppExe "TerreDiCalabria.exe"
#ifndef AppVersion
  #define AppVersion "0.0.1"
#endif

[Setup]
AppId={{D9EAAB31-9287-41CD-AA98-7624EB492FA9}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=danylbd
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=TerreDiCalabria-Setup-{#AppVersion}
SetupIconFile=icona.ico
UninstallDisplayIcon={app}\{#AppExe}
WizardStyle=modern
Compression=lzma2/max
SolidCompression=yes
; Nativo su ARM64 (Snapdragon), versione x64 per tutti gli altri PC
ArchitecturesAllowed=arm64 x64compatible
ArchitecturesInstallIn64BitMode=arm64 x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "italiano"; MessagesFile: "compiler:Languages\Italian.isl"

[Tasks]
Name: "iconadesktop"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\arm64\*"; DestDir: "{app}"; Check: IsArm64; Flags: ignoreversion recursesubdirs
Source: "..\build\x64\*"; DestDir: "{app}"; Check: not IsArm64; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: iconadesktop

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
