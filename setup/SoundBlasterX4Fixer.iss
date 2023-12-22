#define AppName "Sound Blaster X4 Fixer"
#define ServiceName "SoundBlasterX4Fixer"
#define AppVersion "1.1.0"
#define AppAuthor "Adam Szorenyi"
#define AppCopyright "© 2023"
#define Appurl "https://github.com/aszorenyi/soundblasterx4fixer"

; -----------
; SHARED CODE
; -----------
[Code]
// types and variables
type
  TDependency_Entry = record
    Filename: String;
    Parameters: String;
    Title: String;
    URL: String;
    Checksum: String;
    ForceSuccess: Boolean;
    RestartAfter: Boolean;
  end;

var
  Dependency_Memo: String;
  Dependency_List: array of TDependency_Entry;
  Dependency_NeedRestart, Dependency_ForceX86: Boolean;
  Dependency_DownloadPage: TDownloadWizardPage;

procedure Dependency_Add(const Filename, Parameters, Title, URL, Checksum: String; const ForceSuccess, RestartAfter: Boolean);
var
  Dependency: TDependency_Entry;
  DependencyCount: Integer;
begin
  Dependency_Memo := Dependency_Memo + #13#10 + '%1' + Title;

  Dependency.Filename := Filename;
  Dependency.Parameters := Parameters;
  Dependency.Title := Title;

  if FileExists(ExpandConstant('{tmp}{\}') + Filename) then begin
    Dependency.URL := '';
  end else begin
    Dependency.URL := URL;
  end;

  Dependency.Checksum := Checksum;
  Dependency.ForceSuccess := ForceSuccess;
  Dependency.RestartAfter := RestartAfter;

  DependencyCount := GetArrayLength(Dependency_List);
  SetArrayLength(Dependency_List, DependencyCount + 1);
  Dependency_List[DependencyCount] := Dependency;
end;

procedure Dependency_InitializeWizard;
begin
  Dependency_DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

function Dependency_PrepareToInstall(var NeedsRestart: Boolean): String;
var
  DependencyCount, DependencyIndex, ResultCode: Integer;
  Retry: Boolean;
  TempValue: String;
begin
  DependencyCount := GetArrayLength(Dependency_List);

  if DependencyCount > 0 then begin
    Dependency_DownloadPage.Show;

    for DependencyIndex := 0 to DependencyCount - 1 do begin
      if Dependency_List[DependencyIndex].URL <> '' then begin
        Dependency_DownloadPage.Clear;
        Dependency_DownloadPage.Add(Dependency_List[DependencyIndex].URL, Dependency_List[DependencyIndex].Filename, Dependency_List[DependencyIndex].Checksum);

        Retry := True;
        while Retry do begin
          Retry := False;

          try
            Dependency_DownloadPage.Download;
          except
            if Dependency_DownloadPage.AbortedByUser then begin
              Result := Dependency_List[DependencyIndex].Title;
              DependencyIndex := DependencyCount;
            end else begin
              case SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
                IDABORT: begin
                  Result := Dependency_List[DependencyIndex].Title;
                  DependencyIndex := DependencyCount;
                end;
                IDRETRY: begin
                  Retry := True;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    if Result = '' then begin
      for DependencyIndex := 0 to DependencyCount - 1 do begin
        Dependency_DownloadPage.SetText(Dependency_List[DependencyIndex].Title, '');
        Dependency_DownloadPage.SetProgress(DependencyIndex + 1, DependencyCount + 1);

        while True do begin
          ResultCode := 0;
          if ShellExec('', ExpandConstant('{tmp}{\}') + Dependency_List[DependencyIndex].Filename, Dependency_List[DependencyIndex].Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then begin
            if Dependency_List[DependencyIndex].RestartAfter then begin
              if DependencyIndex = DependencyCount - 1 then begin
                Dependency_NeedRestart := True;
              end else begin
                NeedsRestart := True;
                Result := Dependency_List[DependencyIndex].Title;
              end;
              break;
            end else if (ResultCode = 0) or Dependency_List[DependencyIndex].ForceSuccess then begin // ERROR_SUCCESS (0)
              break;
            end else if ResultCode = 1641 then begin // ERROR_SUCCESS_REBOOT_INITIATED (1641)
              NeedsRestart := True;
              Result := Dependency_List[DependencyIndex].Title;
              break;
            end else if ResultCode = 3010 then begin // ERROR_SUCCESS_REBOOT_REQUIRED (3010)
              Dependency_NeedRestart := True;
              break;
            end;
          end;

          case SuppressibleMsgBox(FmtMessage(SetupMessage(msgErrorFunctionFailed), [Dependency_List[DependencyIndex].Title, IntToStr(ResultCode)]), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
            IDABORT: begin
              Result := Dependency_List[DependencyIndex].Title;
              break;
            end;
            IDIGNORE: begin
              break;
            end;
          end;
        end;

        if Result <> '' then begin
          break;
        end;
      end;

      if NeedsRestart then begin
        TempValue := '"' + ExpandConstant('{srcexe}') + '" /restart=1 /LANG="' + ExpandConstant('{language}') + '" /DIR="' + WizardDirValue + '" /GROUP="' + WizardGroupValue + '" /TYPE="' + WizardSetupType(False) + '" /COMPONENTS="' + WizardSelectedComponents(False) + '" /TASKS="' + WizardSelectedTasks(False) + '"';
        if WizardNoIcons then begin
          TempValue := TempValue + ' /NOICONS';
        end;
        RegWriteStringValue(HKA, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', '{#SetupSetting("AppName")}', TempValue);
      end;
    end;

    Dependency_DownloadPage.Hide;
  end;
end;

function Dependency_UpdateReadyMemo(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := '';
  if MemoUserInfoInfo <> '' then begin
    Result := Result + MemoUserInfoInfo + Newline + NewLine;
  end;
  if MemoDirInfo <> '' then begin
    Result := Result + MemoDirInfo + Newline + NewLine;
  end;
  if MemoTypeInfo <> '' then begin
    Result := Result + MemoTypeInfo + Newline + NewLine;
  end;
  if MemoComponentsInfo <> '' then begin
    Result := Result + MemoComponentsInfo + Newline + NewLine;
  end;
  if MemoGroupInfo <> '' then begin
    Result := Result + MemoGroupInfo + Newline + NewLine;
  end;
  if MemoTasksInfo <> '' then begin
    Result := Result + MemoTasksInfo;
  end;

  if Dependency_Memo <> '' then begin
    if MemoTasksInfo = '' then begin
      Result := Result + SetupMessage(msgReadyMemoTasks);
    end;
    Result := Result + FmtMessage(Dependency_Memo, [Space]);
  end;
end;

function Dependency_IsX64: Boolean;
begin
  Result := not Dependency_ForceX86 and Is64BitInstallMode;
end;

function Dependency_String(const x86, x64: String): String;
begin
  if Dependency_IsX64 then begin
    Result := x64;
  end else begin
    Result := x86;
  end;
end;

function Dependency_ArchSuffix: String;
begin
  Result := Dependency_String('', '_x64');
end;

function Dependency_ArchTitle: String;
begin
  Result := Dependency_String(' (x86)', ' (x64)');
end;

function Dependency_IsNetCoreInstalled(const Version: String): Boolean;
var
  ResultCode: Integer;
begin
  // source code: https://github.com/dotnet/deployment-tools/tree/master/src/clickonce/native/projects/NetCoreCheck
  if not FileExists(ExpandConstant('{tmp}{\}') + 'netcorecheck' + Dependency_ArchSuffix + '.exe') then begin
    ExtractTemporaryFile('netcorecheck' + Dependency_ArchSuffix + '.exe');
  end;
  Result := ShellExec('', ExpandConstant('{tmp}{\}') + 'netcorecheck' + Dependency_ArchSuffix + '.exe', Version, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

procedure Dependency_AddDotNet60;
begin
  // https://dotnet.microsoft.com/download/dotnet/8.0
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App 8.0.0') then begin
    Dependency_Add(
      'dotnet80' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 8.0.0' + Dependency_ArchTitle,
      Dependency_String(
        'https://download.visualstudio.microsoft.com/download/pr/593685c9-7e98-455a-8e34-4b8ad1be9489/6ccf85c6fc244428d61f74ca3aee0645/dotnet-runtime-8.0.0-win-x86.exe',
        'https://download.visualstudio.microsoft.com/download/pr/7f4d5cbc-4449-4ea5-9578-c467821f251f/b9b19f89d0642bf78f4b612c6a741637/dotnet-runtime-8.0.0-win-x64.exe'
      ),
      '',
      False,
      False
    );
  end;
end;

[Setup]
#ifndef SoundBlasterX4FixerSetup

; requires netcorecheck.exe and netcorecheck_x64.exe
#define UseNetCoreCheck
#ifdef UseNetCoreCheck
  #define UseDotNet60
#endif

DisableWelcomePage=no
OutputDir=.\
OutputBaseFilename=SoundBlasterX4FixerSetup
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#AppAuthor}
VersionInfoDescription={#AppName}
VersionInfoCopyright={#AppCopyright}, {#AppAuthor}
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}
AllowNoIcons=yes
MinVersion=10.0
AppCopyright={#AppCopyright}, {#AppAuthor}
AppName={#AppName}
AppVerName={#AppName}
RestartIfNeededByRun=false
PrivilegesRequired=none
DefaultDirName={commonpf}\{#AppName}
DefaultGroupName={#AppName}
AlwaysShowComponentsList=false
ShowTasksTreeLines=true
ShowLanguageDialog=auto
AppPublisher={#AppAuthor}
AppSupportURL={#AppUrl}
AppUpdatesURL={#AppUrl}
AppVersion={#AppVersion}
AppID={{27E6B708-2C2A-4762-9313-D8BCA26806A3}
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"

[Dirs]
Name: {app}\runtimes
Name: {app}\runtimes\browser
Name: {app}\runtimes\browser\lib
Name: {app}\runtimes\browser\lib\net6.0
Name: {app}\runtimes\win
Name: {app}\runtimes\win\lib
Name: {app}\runtimes\win\lib\net6.0

[Files]
#ifdef UseNetCoreCheck
// download netcorecheck.exe: https://go.microsoft.com/fwlink/?linkid=2135256
// download netcorecheck_x64.exe: https://go.microsoft.com/fwlink/?linkid=2135504
Source: "tools\netcorecheck.exe"; Flags: dontcopy noencryption
Source: "tools\netcorecheck_x64.exe"; Flags: dontcopy noencryption
#endif
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\runtimes\win\lib\net8.0\System.Diagnostics.EventLog.dll; DestDir: {app}\runtimes\win\lib\net8.0
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\runtimes\win\lib\net8.0\System.Diagnostics.EventLog.Messages.dll; DestDir: {app}\runtimes\win\lib\net8.0
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\runtimes\win\lib\net8.0\System.ServiceProcess.ServiceController.dll; DestDir: {app}\runtimes\win\lib\net8.0
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.Abstractions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.Binder.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.CommandLine.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.EnvironmentVariables.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.FileExtensions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.Json.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Configuration.UserSecrets.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.DependencyInjection.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.DependencyInjection.Abstractions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Diagnostics.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Diagnostics.Abstractions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.FileProviders.Abstractions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.FileProviders.Physical.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.FileSystemGlobbing.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Hosting.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Hosting.Abstractions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Hosting.WindowsServices.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Logging.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Logging.Abstractions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Logging.Configuration.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Logging.Console.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Logging.Debug.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Logging.EventLog.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Logging.EventSource.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Options.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Options.ConfigurationExtensions.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\Microsoft.Extensions.Primitives.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\NAudio.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\NAudio.Asio.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\NAudio.Core.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\NAudio.Extras.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\NAudio.Midi.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\NAudio.Wasapi.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\NAudio.WinMM.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\SoundBlasterX4Fixer.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\SoundBlasterX4Fixer.exe; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\SoundBlasterX4Fixer.deps.json; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\SoundBlasterX4Fixer.runtimeconfig.json; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\System.Diagnostics.EventLog.dll; DestDir: {app}
Source: ..\src\SoundBlasterX4Fixer\bin\Publish\System.ServiceProcess.ServiceController.dll; DestDir: {app}

[Tasks]
Name: StartService; Description: Start the service after installation

[Run]
Filename: {sys}\sc.exe; Parameters: "create {#ServiceName} start= auto binPath= ""{app}\SoundBlasterX4Fixer.exe"" displayName= ""Sound Blaster X4 Fixer Service""" ; Flags: runhidden
Filename: {sys}\sc.exe; Parameters: "description {#ServiceName} ""Fixes distorted notification and system sounds on Creative Sound Blaster X4 USB Sound Cards.""" ; Flags: runhidden
Filename: {sys}\sc.exe; Parameters: "start {#ServiceName}" ; Flags: runhidden nowait ; Tasks: StartService

[Code]

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  case CurUninstallStep of
    usUninstall:
      begin
        Exec(ExpandConstant('{sys}\sc.exe'), ExpandConstant('stop {#ServiceName}'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
        Sleep(1500);
        Exec(ExpandConstant('{sys}\sc.exe'), ExpandConstant('delete {#ServiceName}'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      end;
  end;
end;

procedure InitializeWizard;
begin
  Dependency_InitializeWizard;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := Dependency_PrepareToInstall(NeedsRestart);
end;

function NeedRestart: Boolean;
begin
  Result := Dependency_NeedRestart;
end;

function UpdateReadyMemo(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := Dependency_UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo);
end;

function InitializeSetup: Boolean;
begin
#ifdef UseDotNet60
  Dependency_AddDotNet60;
#endif

  Result := True;
end;
#endif