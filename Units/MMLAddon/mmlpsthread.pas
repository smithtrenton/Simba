{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Venetië and Merlijn Wajer

    MML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MML.  If not, see <http://www.gnu.org/licenses/>.

	See the file COPYING, included in this distribution,
	for details about the copyright.

    MMLPSThread for the Mufasa Macro Library
}

unit mmlpsthread;

{$define PS_USESSUPPORT}

{$mode objfpc}{$H+}

{$I Simba.inc}

interface

uses
  Classes, SysUtils, client,
  {$IFDEF USE_PASCALSCRIPT}
  uPSComponent, uPSCompiler, PSDump, uPSRuntime, uPSPreProcessor,
  {$ENDIF}
  MufasaTypes, MufasaBase, web, fontloader,
  bitmaps, plugins, dynlibs, internets,scriptproperties,
  settings, settingssandbox, lcltype, dialogs, ExtCtrls
  {$IFDEF USE_SQLITE}, msqlite3{$ENDIF}
  {$IFDEF USE_LAPE}
  , lpparser, lpcompiler, lptypes, lpvartypes,
    lpeval, lpinterpreter, lputils, lpexceptions, LPDump
  {$ENDIF};

const
  m_Status = 0; //Data = PChar to new status
  m_Disguise = 1; //Data = PChar to new title
  m_DisplayDebugImgWindow = 2; //Data = PPoint to window size
  m_DrawBitmapDebugImg = 3; //Data = TMufasaBitmap
  m_GetDebugBitmap = 4; //Data = TMufasaBitmap
  m_ClearDebugImg = 5; //Data = nil
  m_ClearDebug = 6; //Data = nil
  m_InputQuery = 7; //Data = PInputQueryData
  m_ShowMessage = 8; //Data = PChar
  m_MessageBox = 9; //Data =  PMessageBoxData
  m_MessageDlg = 10; //Data = PMessageDlg
  m_BalloonHint = 11; //Data = PBalloonHintData

  {$I settings_const.inc}
  {$WARNING REMOVEME}

type
    { TMMLPSThread }
    TCallBackData = record
      FormCallBack : procedure of object;
      cmd : integer;
      data : pointer;
    end;
    PCallBackData = ^TCallBackData;
    TSyncInfo = record
      V : MufasaTypes.PVariantArray;
      MethodName : string;
      Res : ^Variant;
      SyncMethod : procedure of object;
      OldThread : TThread;
    end;

    PSyncInfo = ^TSyncInfo;
    TErrorType = (errRuntime,errCompile);
    TOnError = procedure of object;
    TErrorData = record
      Row,Col,Position : integer;
      Error : string;
      ErrType : TErrorType;
      Module : string;
      IncludePath : string;
    end;
    PErrorData = ^TErrorData;
    TExpMethod = record
      Section : string;
      FuncDecl : string;
      FuncPtr : Pointer;
    end;
    TExpMethodArr = array of TExpMethod;
    TInputQueryData = record
      ACaption, APrompt,Value : String;
      Res : boolean;
    end;
    PInputQueryData = ^TInputQueryData;
    TMessageBoxData = record
      AText, ACaption : PChar;
      AFlags, res : integer;
    end;
    PMessageBoxData = ^TMessageBoxdata;
    TMessageDlgData = record
      ACaption, AMsg : string;
      ADlgType : TMsgDlgType;
      AButtons : TMsgDlgButtons;
      Res : integer;
    end;
    PMessageDlgData = ^TMessageDlgData;

    PBalloonHintData = ^TBalloonHintData;
    TBalloonHintData = record
      ATitle: String;
      AHint: String;
      ATimeout: Integer;
      AFlag: TBalloonFlags;
    end;

    { TMThread }

    TMThread = class(TThread)
    private
      procedure SetOpenConnectionEvent(const AValue: TOpenConnectionEvent);
      procedure SetOpenFileEvent(const AValue: TOpenFileEvent);
      procedure SetWriteFileEvent(const AValue: TWriteFileEvent);
    protected
      AppPath, DocPath, ScriptPath, ScriptFile, IncludePath, PluginPath, FontPath: string;
      DebugTo: TWritelnProc;
      Includes : TStringList;
      FOpenConnectionEvent : TOpenConnectionEvent;
      FWriteFileEvent : TWriteFileEvent;
      FOpenFileEvent : TOpenFileEvent;
      procedure LoadPlugin(plugidx: integer); virtual; abstract;
      function CallMethod(const Method: string; var Args: array of Variant): Variant; virtual; abstract;
      procedure HandleScriptTerminates; virtual;
    public
      Prop: TScriptProperties;
      Client: TClient;
      MInternet: TMInternet;
      Socks: TSocks;
      {$IFDEF USE_SQLITE}SQLite3: TMSQLite3;{$ENDIF}
      StartTime: LongWord;
      Settings: TMMLSettings;
      SimbaSettingsFile: String;
      Sett: TMMLSettingsSandbox;

      CallBackData : PCallBackData; //Handles general callback functions for threadsafety
      SyncInfo : PSyncInfo; //We need this for callthreadsafe
      ErrorData : PErrorData; //We need this for thread-safety etc
      OnError  : TOnError; //Error handeler

      CompileOnly : boolean;

      ExportedMethods: TExpMethodArr;

      procedure FormCallBackEx(cmd : integer; var data : pointer);
      procedure FormCallBack(cmd : integer; data : pointer);
      procedure HandleError(Row, Col, Pos: integer; Error: string; Typ: TErrorType; Filename: string);
      {$IFDEF USE_PASCALSCRIPT}
      function ProcessDirective(Sender: TPSPreProcessor;
                    Parser: TPSPascalPreProcessorParser;
                    Active: Boolean;
                    DirectiveName, DirectiveArgs: string; Filename:String): boolean;
      {$ENDIF}
      function LoadFile(ParentFile: string; var FileName, Content: string): boolean;

      procedure AddMethod(meth: TExpMethod); virtual;

      procedure SetDebug( writelnProc : TWritelnProc );
      procedure SetPath(ScriptP: string);
      procedure SetSettings(S: TMMLSettings; SimbaSetFile: String);
      procedure SetFonts(Fonts: TMFonts); virtual;

      procedure OnThreadTerminate(Sender: TObject);
      procedure SetScript(script: string); virtual; abstract;
      procedure Execute; override; abstract;
      procedure Terminate; virtual; abstract;

      constructor Create(CreateSuspended: boolean; TheSyncInfo : PSyncInfo; plugin_dir: string);
      destructor Destroy; override;

      class function GetExportedMethods: TExpMethodArr; virtual; abstract;

      property OpenConnectionEvent : TOpenConnectionEvent read FOpenConnectionEvent write SetOpenConnectionEvent;
      property WriteFileEvent : TWriteFileEvent read FWriteFileEvent write SetWriteFileEvent;
      property OpenFileEvent : TOpenFileEvent read FOpenFileEvent write SetOpenFileEvent;
    end;

    { TPSThread }
    {$IFDEF USE_PASCALSCRIPT}
    TPSThread = class(TMThread)
      public
        procedure OnProcessDirective(Sender: TPSPreProcessor;
          Parser: TPSPascalPreProcessorParser; const Active: Boolean;
          const DirectiveName, DirectiveParam: string; var Continue: Boolean;
          Filename: String);
        function PSScriptFindUnknownFile(Sender: TObject;
          const OrginFileName: string; var FileName, Output: string): Boolean;
        procedure PSScriptProcessUnknownDirective(Sender: TPSPreProcessor;
          Parser: TPSPascalPreProcessorParser; const Active: Boolean;
          const DirectiveName, DirectiveParam: string; var Continue: Boolean;
          Filename: string);
      protected
        PluginsToload : array of integer;
        procedure LoadPlugin(plugidx: integer); override;
        procedure OnCompile(Sender: TPSScript);
        function RequireFile(Sender: TObject; const OriginFileName: String;
                            var FileName, OutPut: string): Boolean;
        function FileAlreadyIncluded(Sender: TObject; OrgFileName, FileName: string): Boolean;
        function OnIncludingFile(Sender: TObject; OrgFileName, FileName: string): Boolean;

        procedure OnCompImport(Sender: TObject; x: TPSPascalCompiler);
        procedure OnExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
        procedure OutputMessages;
        function CallMethod(const Method: string; var Args: array of Variant): Variant; override;
        procedure HandleScriptTerminates; override;
      public
        PSScript: TPSScriptExtension;
        constructor Create(CreateSuspended: Boolean; TheSyncInfo : PSyncInfo; plugin_dir: string);
        destructor Destroy; override;

        procedure HandleError(Row, Col, Pos: integer; Error: string; Typ: TErrorType; Filename: string);

        class function GetExportedMethods: TExpMethodArr; override;

        procedure SetScript(script: string); override;
        procedure Execute; override;
        procedure Terminate; override;
    end;
    {$ENDIF}

   {$IFDEF USE_LAPE}
   { TLPThread }
   TLPThread = class(TMThread)
   protected
     procedure LoadPlugin(plugidx: integer); override;
     function CallMethod(const Method: string; var Args: array of Variant): Variant; override;
   public
     Parser: TLapeTokenizerString;
     Compiler: TLPCompiler;
     Running: TInitBool;
     ImportWrappers: TList;
     ExportWrappers: TList;

     constructor Create(CreateSuspended: Boolean; TheSyncInfo : PSyncInfo; plugin_dir: string);
     destructor Destroy; override;

     procedure HandleError(Row, Col, Pos: integer; Error: string; Typ: TErrorType; Filename: string);

     class function GetExportedMethods: TExpMethodArr; override;

     procedure SetScript(Script: string); override;
     procedure SetFonts(Fonts: TMFonts); override;
     procedure Execute; override;
     procedure Terminate; override;
     function OnFindFile(Sender: TLapeCompiler; var FileName: lpString): TLapeTokenizerBase;
     function OnHandleDirective(Sender: TLapeCompiler; Directive, Argument: lpString; InPeek: Boolean): Boolean;
   end;

   TSyncMethod = class
   private
     FMethod: Pointer;
   public
     constructor Create(Method: Pointer);
     procedure Call;
   end;

   {$ENDIF}

threadvar
  CurrThread : TMThread;
var
  PluginsGlob: TMPlugins;

implementation

uses
  SimbaUnit,
  colour_conv, dtmutil,
  {$ifdef mswindows}windows,  MMSystem,{$endif}//MMSystem -> Sounds
  {$IFDEF USE_PASCALSCRIPT}
  uPSC_std, uPSC_controls,uPSC_classes,uPSC_graphics,uPSC_stdctrls,uPSC_forms, uPSC_menus,
  uPSC_extctrls, uPSC_mml, uPSC_dll, //Compile-libs
  uPSUtils,
  {$ENDIF}
  IOmanager,//TTarget_Exported
  IniFiles,//Silly INI files
  stringutil, //String st00f
  newsimbasettings, // SimbaSettings
  {$IFDEF USE_DEBUGGER}debugger,{$ENDIF}
  {$IFDEF USE_PASCALSCRIPT}
  uPSR_std, uPSR_controls,uPSR_classes,uPSR_graphics,uPSR_stdctrls,uPSR_forms, uPSR_mml,
  uPSR_menus, uPSR_dll,
  uPSI_ComCtrls, uPSI_Dialogs,
  uPSR_extctrls, //Runtime-libs
  {$ENDIF}
  files,
  dtm, //Dtms!
  Graphics, //For Graphics types
  math, //Maths!
  mmath, //Real maths!
  strutils,
  fileutil,
  tpa, //Tpa stuff
  mmltimer,
  forms,//Forms
  SynRegExpr,
  lclintf,  // for GetTickCount and others.
  Clipbrd,
  lpffi, ffi, // For lape FFI

  DCPcrypt2,
  DCPrc2, DCPrc4, DCPrc5, DCPrc6,
  DCPhaval, DCPmd4, DCPmd5,
  DCPripemd128, DCPripemd160,
  DCPsha1, DCPsha256, DCPsha512,
  DCPtiger

  {$IFDEF USE_LAPE}, lpClasses{$ENDIF};

{$ifdef Linux}
  {$define PS_SafeCall}
{$else}
//{$define PS_SafeCall}
{$endif}
{$MACRO ON}
{$ifdef PS_SafeCall}
  {$define extdecl := safecall}
{$else}
  {$define extdecl := register}
{$endif}

{Some General PS Functions here}
procedure psWriteln(str : string); extdecl;
begin
  if Assigned(CurrThread) and CurrThread.Prop.WriteTimeStamp then
    str := format('[%s]: %s', [TimeToStr(TimeStampToDateTime(MSecsToTimeStamp(GetTickCount - CurrThread.StartTime))), str]);
  if Assigned(CurrThread) and Assigned(CurrThread.DebugTo) then
    CurrThread.DebugTo(str)
  else
    mDebugLn(str);
end;

procedure ps_DebugLn(str : string); extdecl;
begin
  if Assigned(CurrThread) and CurrThread.Prop.WriteTimeStamp then
    str := format('[%s]: %s', [TimeToStr(TimeStampToDateTime(MSecsToTimeStamp(GetTickCount - CurrThread.StartTime))), str]);
  mDebugLn(str);
end;

{***implementation TMThread***}
constructor TMThread.Create(CreateSuspended: boolean; TheSyncInfo: PSyncInfo; plugin_dir: string);
begin
  inherited Create(CreateSuspended);

  Client := TClient.Create(plugin_dir);
  if Assigned(WriteFileEvent) then
    Client.MFiles.WriteFileEvent := WriteFileEvent;
  if Assigned(OpenFileEvent) then
    Client.MFiles.OpenFileEvent := OpenFileEvent;
  MInternet := TMInternet.Create(Client);
  Socks := TSocks.Create(Client);
  {$IFDEF USE_SQLITE}
  SQLite3 := TMSQLite3.Create(Client);
  {$ENDIF}
  if Assigned(OpenConnectionEvent) then
    MInternet.OpenConnectionEvent := Self.OpenConnectionEvent;
  SyncInfo:= TheSyncInfo;
  ExportedMethods:= GetExportedMethods;
  FreeOnTerminate := True;
  CompileOnly := false;
  OnTerminate := @OnThreadTerminate;
  OnError:= nil;
  Includes := TStringList.Create;
  Includes.CaseSensitive := {$ifdef linux}true{$else}false{$endif};
  Sett := nil;

  Prop := TScriptProperties.Create;

  AppPath := Application.Location;
  DocPath := SimbaSettings.Scripts.Path.Value;
  IncludePath := SimbaSettings.Includes.Path.Value;
  PluginPath := SimbaSettings.Plugins.Path.Value;
  FontPath := SimbaSettings.Fonts.Path.Value;
end;

destructor TMThread.Destroy;
begin
  MInternet.Free;
  Socks.Free;
  {$IFDEF USE_SQLITE}SQLite3.Free;{$ENDIF}
  Client.Free;
  Includes.free;
  Prop.Free;
  if Sett <> nil then
    Sett.Free;
  inherited Destroy;
end;

procedure TMThread.SetOpenConnectionEvent(const AValue: TOpenConnectionEvent);
begin
  FOpenConnectionEvent:= AValue;
  if Assigned(MInternet) then
    self.MInternet.OpenConnectionEvent := AValue;
end;

procedure TMThread.SetOpenFileEvent(const AValue: TOpenFileEvent);
begin
  FOpenFileEvent:= AValue;
  if Assigned(Client) then
    self.Client.MFiles.OpenFileEvent := AValue;
end;

procedure TMThread.SetWriteFileEvent(const AValue: TWriteFileEvent);
begin
  FWriteFileEvent:= AValue;
  if Assigned(Client) then
    self.Client.MFiles.WriteFileEvent := AValue;
end;

procedure TMThread.FormCallBackEx(cmd: integer; var data: pointer);
begin
  if (CallBackData = nil) or not Assigned(CallBackData^.FormCallBack) then
    exit;
  CallBackData^.cmd:= cmd;
  CallBackData^.data:= data;
  Synchronize(CallBackData^.FormCallBack);
  data := CallBackData^.data;
end;

procedure TMThread.FormCallBack(cmd: integer; data: pointer);
begin
  if (CallBackData = nil) or (not Assigned(CallBackData^.FormCallBack)) then
    exit;
  CallBackData^.cmd:= cmd;
  CallBackData^.data:= data;
  Synchronize(CallBackData^.FormCallBack);
end;

procedure TMThread.HandleError(Row, Col, Pos: integer; Error: string; Typ: TErrorType; Filename: string);
begin
  if (OnError = nil) then
    Exit;

  ErrorData^.Row := Row;
  ErrorData^.Col := Col;
  ErrorData^.Position := Pos;
  ErrorData^.Error := Error;
  ErrorData^.ErrType := Typ;
  ErrorData^.Module := Filename;
  ErrorData^.IncludePath := IncludePath;

  CurrThread.Synchronize(OnError);
end;

procedure TMThread.OnThreadTerminate(Sender: TObject);
begin

end;

procedure TMThread.AddMethod(meth: TExpMethod);
begin
  raise Exception.Create('AddMethod not Implememnted!');
end;

function TMThread.LoadFile(ParentFile: string; var FileName, Content: string): boolean;
begin
  Result := FindFile(FileName, [IncludeTrailingPathDelimiter(ExtractFileDir(ParentFile)), IncludePath, ScriptPath]);
  if (not (Result)) then
    Exit;

  if (Includes.IndexOf(FileName) = -1) then
    Includes.Add(FileName);

  try
    with TFileStream.Create(UTF8ToSys(FileName), fmOpenRead) do
    try
      SetLength(Content, Size);
      Read(Content[1], Length(Content));
    finally
      Free;
    end;
  except
    Result := False;
    psWriteln('ERROR in TMThread.LoadFile');
  end;
end;

{$IFDEF USE_PASCALSCRIPT}
function TMThread.ProcessDirective(Sender: TPSPreProcessor;
        Parser: TPSPascalPreProcessorParser;
        Active: Boolean;
        DirectiveName, DirectiveArgs: string; FileName: string): boolean;
var
  plugin_idx: integer;

begin
  Result := False;

  if (CompareText(DirectiveName,'LOADLIB') = 0) then
  begin
    if (not (Active)) then
      Exit(True);

    if (DirectiveArgs <> '') then
    begin
      plugin_idx := PluginsGlob.LoadPlugin(DirectiveArgs);

      if (plugin_idx >= 0) then
      begin
        LoadPlugin(plugin_idx);

        if (not (PluginsGlob.MPlugins[plugin_idx].MemMgrSet)) then
          mDebugLn(Format('The DLL "%s" doesn''t set a memory manager.', [DirectiveArgs]));

        Result := True;
      end else
        psWriteln(Format('Your DLL %s has not been found.', [DirectiveArgs]))
    end else
      psWriteln('Your LoadLib directive has no params, thus cannot find the plugin');
  end else if CompareText(DirectiveName,'WARNING') = 0 then
  begin
    if not active then
      exit(true);
    if (sender = nil) or (parser = nil) then
    begin
      psWriteln('ERROR: WARNING directive not supported for this interpreter');
      exit(False);
    end;

    if (DirectiveArgs <> '') then
    begin
      Result := True;
      if FileName = '' then
        psWriteln(format('Warning: In %s: at row: %d, col: %d, pos %d: %s',
                               ['Main script', Parser.row - 1, Parser.col,
                               Parser.pos, DirectiveArgs]))
      else
        psWriteln(format('Warning: In file %s: at row: %d, col: %d, pos %d: %s',
                             [FileName, Parser.row - 1, Parser.col,
                             Parser.pos, DirectiveArgs]));
      //HandleError(Parser.Row + 1, Parser.Col, Parser.Pos, 'Warning at ' + DirectiveArgs, errCompile, FileName);
    end;
  end else if CompareText(DirectiveName,'ERROR') = 0 then
  begin
    if not active then
      exit(true);
    if (sender = nil) or (parser = nil) then
    begin
      psWriteln('ERROR: ERROR directive not supported for this interpreter');
      exit(False);
    end;

    if (DirectiveArgs <> '') then
    begin
      Result := True;
      HandleError(Parser.Row, Parser.Col, Parser.Pos, DirectiveArgs, errCompile, FileName);
      raise EPSPreProcessor.Create('ERROR directive found');
    end;
  end else
    Result := False;
end;
{$ENDIF}

procedure TMThread.SetDebug(writelnProc: TWritelnProc);
begin
  DebugTo := writelnProc;
  Client.WritelnProc:= writelnProc;
end;

procedure TMThread.SetSettings(S: TMMLSettings; SimbaSetFile: String);
begin
  Self.SimbaSettingsFile := SimbaSetFile;
  Self.Settings := S;
  Self.Sett := TMMLSettingsSandbox.Create(Self.Settings);
  Self.Sett.prefix := 'Scripts/';
end;

procedure TMThread.SetPath(ScriptP: string);
begin
  ScriptPath := IncludeTrailingPathDelimiter(ExpandFileName(ExtractFileDir(ScriptP)));
  ScriptFile := ExtractFileName(ScriptP);
end;

procedure TMThread.SetFonts(Fonts: TMFonts);
begin
  if Assigned(Fonts) then
    Client.MOCR.Fonts := Fonts;
end;

procedure TMThread.HandleScriptTerminates;
var
  I: integer;
  V: array of Variant;
begin
  SetLength(V, 0);
  if (SP_OnTerminate in Prop.Properties) then
    for I := 0 to Prop.OnTerminateProcs.Count - 1 do
      CallMethod(Prop.OnTerminateProcs[I], V);
end;

{$IFDEF USE_PASCALSCRIPT}
function ThreadSafeCall(aProcName: string; var V: TVariantArray): Variant; extdecl;
begin
  if GetCurrentThreadId = MainThreadID then
  begin
    with TPSThread(currthread).PSScript do
      Result := Exec.RunProcPVar(V,Exec.GetProc(aProcName));
  end else
  begin
    CurrThread.SyncInfo^.MethodName:= aProcName;
    CurrThread.SyncInfo^.V:= @V;
    CurrThread.SyncInfo^.OldThread := CurrThread;
    CurrThread.SyncInfo^.Res := @Result;
    CurrThread.Synchronize(CurrThread.SyncInfo^.SyncMethod);
  end;
end;

function CallProc(aProcName: string; var V: TVariantArray): Variant; extdecl;
begin
  with TPSThread(currthread).PSScript do
    Result := Exec.RunProcPVar(V,Exec.GetProc(aProcName));
end;
{$ENDIF}

{$I PSInc/Wrappers/other.inc}
{$I PSInc/Wrappers/settings.inc}
{$I PSInc/Wrappers/bitmap.inc}

{$I PSInc/Wrappers/window.inc}
{$I PSInc/Wrappers/tpa.inc}
{$I PSInc/Wrappers/strings.inc}

{$I PSInc/Wrappers/crypto.inc}
{$I PSInc/Wrappers/colour.inc}
{$I PSInc/Wrappers/colourconv.inc}
{$I PSInc/Wrappers/math.inc}
{$IFDEF USE_SQLITE}
{$I PSInc/Wrappers/ps_sqlite3.inc}
{$ENDIF}
{$I PSInc/Wrappers/mouse.inc}
{$I PSInc/Wrappers/file.inc}
{$I PSInc/Wrappers/keyboard.inc}
{$I PSInc/Wrappers/dtm.inc}
{$I PSInc/Wrappers/ocr.inc}
{$I PSInc/Wrappers/internets.inc}
{$IFDEF USE_PASCALSCRIPT}
{$I PSInc/psmethods.inc}

{***implementation TPSThread***}

constructor TPSThread.Create(CreateSuspended : boolean; TheSyncInfo : PSyncInfo; plugin_dir: string);
var
  I, H: LongInt;
begin
  inherited Create(CreateSuspended, TheSyncInfo, plugin_dir);
  PSScript := TPSScriptExtension.Create(nil);
  PSScript.UsePreProcessor := True;
  PSScript.UseDebugInfo := True;
  PSScript.CompilerOptions := PSScript.CompilerOptions + [icBooleanShortCircuit];
  PSScript.OnNeedFile := @RequireFile;
  PSScript.OnIncludingFile := @OnIncludingFile;
  PSScript.OnFileAlreadyIncluded := @FileAlreadyIncluded;
  PSScript.OnProcessDirective := @OnProcessDirective;
  PSScript.OnProcessUnknowDirective := @PSScriptProcessUnknownDirective;
  PSScript.OnCompile := @OnCompile;
  PSScript.OnCompImport := @OnCompImport;
  PSScript.OnExecImport := @OnExecImport;
  PSScript.OnFindUnknownFile := @PSScriptFindUnknownFile;

  {$IFDEF USE_DEBUGGER}
  DebuggerForm.DebugThread := Self;
  if (SimbaForm.CurrScript.SynEdit.Marks.Count > 0) then
    TThread.Synchronize(nil, @DebuggerForm.ShowForm);
  {$ENDIF}

  with PSScript do
  begin
    // Set some defines
    {$I PSInc/psdefines.inc}
  end;

  H := High(ExportedMethods);
  for I := 0 to H do
    if (Pos('Writeln', ExportedMethods[i].FuncDecl) > 0) then
    begin
      ExportedMethods[i].FuncPtr := nil;
      Break;
    end;
end;


destructor TPSThread.Destroy;
begin
  PSScript.Free;
  inherited;
end;

class function TPSThread.GetExportedMethods: TExpMethodArr;
var
  c : integer;
  CurrSection : string;

procedure SetCurrSection(str : string);
begin;
  CurrSection := Str;
end;

procedure AddFunction( Ptr : Pointer; DeclStr : String);
begin;
  if c >= 600 then
    raise exception.create('TMThread.LoadMethods: Exported more than 600 functions');

  Result[c].FuncDecl:= DeclStr;
  Result[c].FuncPtr:= Ptr;
  Result[c].Section:= CurrSection;

  Inc(c);
end;

begin
  c := 0;
  CurrSection := 'Other';
  SetLength(Result, 550);

  {$i PSInc/psexportedmethods.inc}

  SetLength(Result, c);
end;

procedure TPSThread.OnProcessDirective(Sender: TPSPreProcessor;
  Parser: TPSPascalPreProcessorParser; const Active: Boolean;
  const DirectiveName, DirectiveParam: string; var Continue: Boolean; Filename: String);
begin
  if (CompareText(DirectiveName, 'LOADLIB') = 0)
  or (CompareText(DirectiveName, 'WARNING') = 0)
  or (CompareText(DirectiveName, 'ERROR') = 0)  then
    Continue := not ProcessDirective(Sender, Parser, Active, DirectiveName,DirectiveParam,
             FileName);
end;

function TPSThread.PSScriptFindUnknownFile(Sender: TObject;
  const OrginFileName: string; var FileName, Output: string): Boolean;
begin
  mDebugLn(OrginFileName + '-' +  Output + '-' + FileName);
  Result := false;
end;

procedure TPSThread.PSScriptProcessUnknownDirective(Sender: TPSPreProcessor;
  Parser: TPSPascalPreProcessorParser; const Active: Boolean;
  const DirectiveName, DirectiveParam: string; var Continue: Boolean;
  Filename: string);
begin
  Continue:= not ProcessDirective(Sender, Parser, Active, DirectiveName,
             DirectiveParam, FileName);
end;

function Muf_Conv_to_PS_Conv( conv : integer) : TDelphiCallingConvention;
begin
  case conv of
    cv_StdCall : result := cdStdCall;
    cv_Register: result := cdRegister;

    cv_Default: result :=
    {$IFDEF CPU32}
    cdCdecl;
    {$ELSE}
    cdCdecl; // this shouldn't matter at all
    {$ENDIF}
  else
    raise exception.createfmt('Unknown Calling Convention[%d]',[conv]);
  end;
end;

procedure TPSThread.LoadPlugin(plugidx: integer);
var
 i: integer;
begin
  for i := High(PluginsToLoad) downto 0 do
    if PluginsToLoad[i] = plugidx then
      Exit;
  SetLength(PluginsToLoad,Length(PluginsToLoad)+1);
  PluginsToLoad[High(PluginsToLoad)]:= plugidx;
end;

procedure TPSThread.OnCompile(Sender: TPSScript);
var
  i,ii : integer;
  Fonts : TMFonts;
begin
  Fonts := Client.MOCR.Fonts;
  for i := fonts.count - 1 downto 0 do
    Sender.Comp.AddConstantN(Fonts[i].Name,'string').SetString(Fonts[i].Name);

  for i := High(PluginsToLoad) downto 0 do
  begin
    for ii := 0 to PluginsGlob.MPlugins[PluginsToLoad[i]].TypesLen - 1 do
      Sender.Comp.AddTypeS(PluginsGlob.MPlugins[PluginsToLoad[i]].Types[ii].TypeName,
                      PluginsGlob.MPlugins[PluginsToLoad[i]].Types[ii].TypeDef);

    for ii := 0 to PluginsGlob.MPlugins[PluginsToLoad[i]].MethodLen - 1 do
      Sender.AddFunctionEx(PluginsGlob.MPlugins[PluginsToLoad[i]].Methods[ii].FuncPtr,
                           PluginsGlob.MPlugins[PluginsToLoad[i]].Methods[ii].FuncStr,
                           Muf_Conv_to_PS_Conv(PluginsGlob.MPlugins[PluginsToLoad[i]].Methods[ii].FuncConv));
  end;
  
  for i := 0 to high(VirtualKeys) do
    Sender.Comp.AddConstantN(Format('VK_%S',[VirtualKeys[i].Str]),'Byte').SetInt(VirtualKeys[i].Key);
  // Here we add all the Consts/Types to the engine.

  //Export all the methods
  for i := 0 to high(ExportedMethods) do
    if ExportedMethods[i].FuncPtr <> nil then
      Sender.AddFunctionEx(ExportedMethods[i].FuncPtr,ExportedMethods[i].FuncDecl,
                             {$ifdef PS_SafeCall}cdSafeCall{$else}cdRegister{$endif});
end;

function TPSThread.RequireFile(Sender: TObject; const OriginFileName: string; var FileName, OutPut: string): Boolean;
var
  File_MD5{$IFDEF SIMBA_VERBOSE}, OriginalFileName{$ENDIF}: string;
begin
  {$IFDEF SIMBA_VERBOSE}OriginalFileName := FileName;{$ENDIF}
  Result := LoadFile(OriginFileName, FileName, OutPut);

  if Result then
  begin
    {$IFDEF SIMBA_VERBOSE}mDebugLn('RequireFile(0x%P, ''%S'', ''%S'' => ''%S'') = %S;', [Pointer(Sender), OriginFileName, OriginalFileName, FileName, BoolToStr(Result, True)]);{$ENDIF}
    File_MD5 := UpperCase(_Hash(TDCP_md5, Output));

    Output := '{$IFNDEF IS_INCLUDE}' +
              '{$DEFINE __REMOVE_IS_INCLUDE_' + File_MD5 + '_}' +
              '{$DEFINE IS_INCLUDE}' +
              '{$ENDIF}' +

              LineEnding + Output + LineEnding +

              '{$IFDEF __REMOVE_IS_INCLUDE_' + File_MD5 + '_}' +
              '{$UNDEF IS_INCLUDE}' +
              '{$UNDEF __REMOVE_IS_INCLUDE_' + File_MD5 + '_}' +
              '{$ENDIF}';
  end;
end;

function TPSThread.FileAlreadyIncluded(Sender: TObject; OrgFileName, FileName: string): Boolean;
var
  Path: string;
begin
  Result := True;

  Path := FileName;
  if (not (FindFile(Path, [IncludeTrailingPathDelimiter(ExtractFileDir(OrgFileName)), ScriptPath, IncludePath]))) then
    Exit;

  Path := ExpandFileNameUTF8(Path);

  if ((Path <> '') and (Includes.IndexOf(Path) <> -1)) then
  begin
    {$IFDEF SIMBA_VERBOSE}
    mDebugLn('Include_Once file already included:' + Path);
    {$ENDIF}
    Exit;
  end;

  {$IFDEF SIMBA_VERBOSE}
  mDebugLn('OnFileAlreadyIncluded, Adding: ' + path);
  {$ENDIF}
  Includes.Add(Path);
  Result := False;
end;

function TPSThread.OnIncludingFile(Sender: TObject; OrgFileName, FileName: string): Boolean;
var
  Path: string;
begin
  Result := True;

  Path := FileName;
  if (not (FindFile(Path, [IncludeTrailingPathDelimiter(ExtractFileDir(OrgFileName)), ScriptPath, IncludePath]))) then
    Exit;

  Path := ExpandFileNameUTF8(Path);

  if (Includes.IndexOf(Path) = -1) then
  begin
    {$IFDEF SIMBA_VERBOSE}
    mDebugLn('OnIncludingFile, Adding: ' + Path);
    {$ENDIF}
    Includes.Add(Path);
  end;
end;

procedure SIRegister_Mufasa(cl: TPSPascalCompiler);
begin
  SIRegister_MML(cl);
end;

procedure TPSThread.OnCompImport(Sender: TObject; x: TPSPascalCompiler);
begin
  SIRegister_Std(x);
  SIRegister_Classes(x, True);
  SIRegister_Controls(x);
  SIRegister_Graphics(x, True);
  SIRegister_Forms(x);
  SIRegister_stdctrls(x);
  SIRegister_ExtCtrls(x);
  SIRegister_Menus(x);
  SIRegister_ComCtrls(x);
  SIRegister_Dialogs(x);
  
  if self.settings <> nil then
  begin
    if lowercase(self.settings.GetKeyValueDefLoad(ssInterpreterAllowSysCalls,
      'False', Self.SimbaSettingsFile)) = 'true' then
    begin
      { Can remove later }
      psWriteln('Allowing API/SysCalls.');
      RegisterDll_Compiletime(x);
    end;
  end;

  with x do
  begin
    {$I PSInc/pscompile.inc}
  end;

  SIRegister_Mufasa(x);

  with x.AddFunction('procedure writeln;').Decl.AddParam do
  begin
    OrgName := 'x';
    Mode := pmIn;
  end;

  with x.AddFunction('function ToStr:string').Decl.AddParam do
  begin
    OrgName := 'x';
    Mode := pmIn;
  end;

  with x.AddFunction('procedure swap;').Decl do
  begin
    with AddParam do
    begin
      OrgName := 'x';
      Mode := pmInOut;
    end;

    with AddParam do
    begin
      OrgName := 'y';
      Mode := pmInOut;
    end;
  end;

  with x.AddFunction('procedure Insert;').Decl do
  begin
    with AddParam do
    begin
      OrgName := 'Item';
      Mode := pmInOut;  //NOTE: InOut because of DynamicArrays
    end;

    with AddParam do
    begin
      OrgName := 'Obj';
      Mode := pmInOut;
    end;

    with AddParam do
    begin
      OrgName := 'Index';
      Mode := pmIn;
    end;
  end;

  with x.AddFunction('procedure Append;').Decl do
  begin
    with AddParam do
    begin
      OrgName := 'Item';
      Mode := pmInOut;  //NOTE: InOut because of DynamicArrays
    end;

    with AddParam do
    begin
      OrgName := 'Obj';
      Mode := pmInOut;
    end;
  end;

  with x.AddFunction('procedure Delete;').Decl do
  begin
    with AddParam do
    begin
      OrgName := 'x';
      Mode := pmInOut;
    end;

    with AddParam do
    begin
      OrgName := 'Index';
      Mode := pmIn;
    end;

    with AddParam do
    begin
      OrgName := 'Count';
      Mode := pmIn;
    end;
  end;
end;

function TMufasaBitmapCreate: TMufasaBitmap;
begin
  Result := TMufasaBitmap.Create;
  CurrThread.Client.MBitmaps.AddBMP(result);
end;

procedure TMufasaBitmapFree(Self: TMufasaBitmap);
begin
  Self.Free();
end;

function TMufasaBitmapCopy(Self : TMufasaBitmap;const xs,ys,xe,ye : integer) : TMufasaBitmap;
begin
  result := Self.Copy(xs,ys,xe,ye);
  CurrThread.Client.MBitmaps.AddBMP(result);
end;
function TMDTMCreate : TMDTM;
begin
  result := TMDTM.Create;
  CurrThread.Client.MDTMs.AddDTM(result);
end;
procedure TMDTMFree(Self : TMDTM);
begin
  CurrThread.Client.MDTMs.FreeDTM(self.Index);
end;

procedure RIRegister_Mufasa(CL: TPSRuntimeClassImporter);
begin
  RIRegister_MML(cl);
 //Overwrites the default stuff
  with cl.FindClass('TMufasaBitmap') do
  begin
    RegisterConstructor(@TMufasaBitmapCreate,'Create');
    RegisterMethod(@TMufasaBitmapFree,'Free');
    RegisterMethod(@TMufasaBitmapCopy,'Copy');
  end;
  With cl.FindClass('TMDTM') do
  begin
    RegisterConstructor(@TMDTMCreate,'Create');
    RegisterMethod(@TMDTMFree,'Free');
  end;
end;

function Insert_(Caller: TPSExec; p: TPSExternalProcRec; Global, Stack: TPSStack): Boolean;
var
  Item, Obj: TPSVariantIFC;
  Index, Len, ItemSize, ItemLen, I: Int32;
  PArr, DArr: PByte;
begin
  Result := True;
  if (Stack.Count > 3) then
    raise Exception.Create('Too many parameters');
  if (Stack.Count < 2) then
    raise Exception.Create('Not enough parameters');

  Item := NewTPSVariantIFC(Stack[Stack.Count - 1], False);
  Obj := NewTPSVariantIFC(Stack[Stack.Count - 2], True);

  Index := -1;
  if (Stack.Count = 3) then
    Index := Stack.GetInt(-3);

  if ((Item.Dta = nil) or (Obj.Dta = nil)) then
    raise Exception.Create('Invalid parameter');

  case Obj.aType.BaseType of
    btArray: begin
        Len := PSDynArrayGetLength(PPointer(Obj.Dta)^, Obj.aType);
        if (Index = -1) or (Index > Len) then
          Index := Len;

        if (Obj.aType.RealSize <> Item.aType.RealSize) then
            raise Exception.Create('Invalid parameter');

        ItemSize := Obj.aType.RealSize;
        ItemLen := 1;

        if (Item.aType.BaseType = btArray) then
          ItemLen := PSDynArrayGetLength(PPointer(Item.Dta)^, Item.aType);

        PSDynArraySetLength(PPointer(Obj.Dta)^, Obj.aType, Len + ItemLen);

        PArr := PByte(Obj.Dta^);
        DArr := PByte(Item.Dta^);

        if (Index < Len) then
          Move(PArr[Index * ItemSize], PArr[(Index + ItemLen) * ItemSize], (Len - Index) * ItemSize);

        if (Item.aType.BaseType = btArray) then //FIXME: Only want DynArrays here....
          Move(DArr[0], PArr[Index * ItemSize], ItemSize * ItemLen)
        else
          Move(DArr, PArr[Index * ItemSize], ItemSize * ItemLen);
      end;
    btString: begin
        if (Index = -1) then
          Index := Length(PString(Obj.Dta)^) + 1;

        case Item.aType.BaseType of
          btString: Insert(PString(Item.Dta)^, PString(Obj.Dta)^, Index);
          btChar: Insert(PChar(Item.Dta)^, PString(Obj.Dta)^, Index);
          btWideString, btUnicodeString: Insert(PWideString(Item.Dta)^, PString(Obj.Dta)^, Index);
          btWideChar: Insert(PWideChar(Item.Dta)^, PString(Obj.Dta)^, Index);
          else
            raise Exception.Create('Invalid parameter');
        end;
      end;
    btWideString, btUnicodeString: begin
        if (Index = -1) then
          Index := Length(PWideString(Obj.Dta)^) + 1;

        case Item.aType.BaseType of
          btString: Insert(PString(Item.Dta)^, PWideString(Obj.Dta)^, Index);
          btChar: Insert(PChar(Item.Dta)^, PWideString(Obj.Dta)^, Index);
          btWideString, btUnicodeString: Insert(PWideString(Item.Dta)^, PWideString(Obj.Dta)^, Index);
          btWideChar: Insert(PWideChar(Item.Dta)^, PWideString(Obj.Dta)^, Index);
          else
            raise Exception.Create('Invalid parameter');
        end;
      end;
    else
      raise Exception.Create('Invalid parameter');
  end;
end;

function Delete_(Caller: TPSExec; p: TPSExternalProcRec; Global, Stack: TPSStack): Boolean;
var
  Param: TPSVariantIFC;
  ItemSize, Len, Index, Count: Int32;
  PArr: PByte;
begin
  Result := True;
  if (Stack.Count > 3) then
    raise Exception.Create('Too many parameters');
  if (Stack.Count < 3) then
    raise Exception.Create('Not enough parameters');

  Param := NewTPSVariantIFC(Stack[Stack.Count - 1], True);
  if (Param.Dta = nil) then
    raise Exception.Create('Invalid parameter');

  Index := Stack.GetInt(-2);
  Count := Stack.GetInt(-3);

  case Param.aType.BaseType of
    btWideString, btUnicodeString: Delete(PWideString(Param.Dta)^, Index , Count);
    btString: Delete(PString(Param.Dta)^, Index, Count);
    btArray: begin
        ItemSize := TPSTypeRec_Array(Param.aType).ArrayType.RealSize;
        Len := PSDynArrayGetLength(PPointer(Param.Dta)^, Param.aType);

        if ((Index < 0) or (Index >= Len)) then
          raise Exception.Create('Out of array range');

        PArr := PByte(Param.Dta^);
        Move(PArr[(Index + Count) * ItemSize], PArr[Index * ItemSize], (Len - (Index + Count)) * ItemSize);

        PSDynArraySetLength(PPointer(Param.Dta)^, Param.aType, Len - Count);
      end;
    else
      raise Exception.Create('Invalid parameter type');
  end;
end;

procedure TPSThread.OnExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
  RIRegister_Std(x);
  RIRegister_Classes(x, True);
  RIRegister_Controls(x);
  RIRegister_Graphics(x, True);
  RIRegister_Forms(x);
  RIRegister_stdctrls(x);
  RIRegister_ExtCtrls(x);
  RIRegister_Menus(x);
  RIRegister_Mufasa(x);
  RIRegister_ComCtrls(x);
  RIRegister_Dialogs(x);
  RegisterDLLRuntime(se);

  se.RegisterFunctionName('WriteLn',@Writeln_,nil,nil);
  se.RegisterFunctionName('ToStr',@ToStr_,nil,nil);
  se.RegisterFunctionName('Swap',@swap_,nil,nil);

  se.RegisterFunctionName('Append', @Insert_, nil, nil);
  se.RegisterFunctionName('Insert', @Insert_, nil, nil);
  se.RegisterFunctionName('Delete', @Delete_, nil, nil);
end;

procedure TPSThread.OutputMessages;
var
  l: Longint;
  b: Boolean;
begin
  b := False;
  for l := 0 to PSScript.CompilerMessageCount - 1 do
  begin
    if (not b) and (PSScript.CompilerMessages[l] is TIFPSPascalCompilerError) then
    begin
      b := True;
      if OnError <> nil then
        with PSScript.CompilerMessages[l] do
          HandleError(Row, Col, Pos, MessageToString, errCompile, ModuleName)
      else
        psWriteln(PSScript.CompilerErrorToStr(l) + ' at line ' + inttostr(PSScript.CompilerMessages[l].Row - 1));
    end else
      psWriteln(PSScript.CompilerErrorToStr(l) + ' at line ' + inttostr(PSScript.CompilerMessages[l].Row - 1));
  end;
end;

function TPSThread.CallMethod(const Method: string; var Args: array of Variant): Variant;
begin
  Result := PSScript.ExecuteFunction(Args, Method);
end;

procedure TPSThread.HandleScriptTerminates;
begin
  if (PSScript.Exec.ExceptionCode = ErNoError) then
    inherited;
end;

procedure TPSThread.Execute;
begin
  CurrThread := Self;
  Starttime := lclintf.GetTickCount;

  try
    if PSScript.Compile then
    begin
      OutputMessages;
      psWriteln('Compiled successfully in ' + IntToStr(GetTickCount - Starttime) + ' ms.');
      if CompileOnly then
        exit;
//      if not (ScriptState = SCompiling) then
        if not PSScript.Execute then
          HandleError(PSScript.ExecErrorRow, PSScript.ExecErrorCol, PSScript.ExecErrorPosition, PSScript.ExecErrorToString,
                      errRuntime, PSScript.ExecErrorFileName)
        else
        begin
          HandleScriptTerminates;
          psWriteln('Successfully executed.');
        end;
    end else
    begin
      OutputMessages;
      psWriteln('Compiling failed.');
    end;
  except
     on E : Exception do
       psWriteln('Exception in Script: ' + e.message);
  end;
end;

procedure TPSThread.Terminate;
begin
  PSScript.Stop;
end;

procedure TPSThread.SetScript(script: string);
begin
   PSScript.Script.Text := LineEnding + Script; //A LineEnding to conform with the info we add to includes
end;

procedure TPSThread.HandleError(Row, Col, Pos: integer; Error: string; Typ: TErrorType; Filename: string);
begin
  inherited HandleError(Row + 1, Col, Pos, Error, Typ, Filename);
end;
{$ENDIF}

{$IFDEF USE_LAPE}
{ TLPThread }

type
  PBoolean = ^Boolean;
  PStringArray = ^TStringArray;
  PBmpMirrorStyle = ^TBmpMirrorStyle;
  PPointArray = ^TPointArray;
  P2DIntArray = ^T2DIntArray;
  PCanvas = ^TCanvas;
  P2DPointArray = ^T2DPointArray;
  PMask = ^TMask;
  PBox = ^TBox;
  PTarget_Exported = ^TTarget_Exported;
  PIntegerArray = ^TIntegerArray;
  PExtendedArray = ^TExtendedArray;
  P2DIntegerArray = ^T2DIntegerArray;
  PFont = ^TFont;
//  PStrExtr = ^TStrExtr;
  PReplaceFlags = ^TReplaceFlags;
  PClickType = ^TClickType;
  P2DExtendedArray = ^T2DExtendedArray;
  PMDTM = ^TMDTM;
  PMDTMPoint = ^TMDTMPoint;
  PSDTM = ^TSDTM;
  PMsgDlgType = ^TMsgDlgType;
  PMsgDlgButtons = ^TMsgDlgButtons;
  PClient = ^TClient;
  PStrings = ^TStrings;

threadvar
  WriteLnStr: string;

procedure lp_Write(Params: PParamArray); lape_extdecl
begin
  WriteLnStr += PlpString(Params^[0])^;
end;

procedure lp_WriteLn(Params: PParamArray); lape_extdecl
begin
  psWriteLn(WriteLnStr);
  WriteLnStr := '';
end;

procedure lp_DebugLn(Params: PParamArray); lape_extdecl
begin
  ps_debugln(PlpString(Params^[0])^);
end;

procedure lp_Sync(Params: PParamArray); lape_extdecl
var
  Method: TSyncMethod;
begin
  Method := TSyncMethod.Create(PPointer(Params^[0])^);
  try
    TThread.Synchronize(CurrThread, @Method.Call);
  finally
    Method.Free();
  end;
end;

procedure lp_CurrThreadID(Params: PParamArray; Result: Pointer); lape_extdecl
begin
  PPtrUInt(Result)^ := GetCurrentThreadID();
end;

{$I LPInc/Wrappers/lp_other.inc}

{$I LPInc/Wrappers/lp_settings.inc}
{$I LPInc/Wrappers/lp_bitmap.inc}

{$I LPInc/Wrappers/lp_window.inc}
{$I LPInc/Wrappers/lp_tpa.inc}
{$I LPInc/Wrappers/lp_strings.inc}
{$I LPInc/Wrappers/lp_colour.inc}
{$I LPInc/Wrappers/lp_colourconv.inc}
{$I LPInc/Wrappers/lp_crypto.inc}
{$I LPInc/Wrappers/lp_math.inc}
{$IFDEF USE_SQLITE}
{$I LPInc/Wrappers/lp_sqlite3.inc}
{$ENDIF}
{$I LPInc/Wrappers/lp_mouse.inc}
{$I LPInc/Wrappers/lp_file.inc}
{$I LPInc/Wrappers/lp_keyboard.inc}
{$I LPInc/Wrappers/lp_dtm.inc}
{$I LPInc/Wrappers/lp_ocr.inc}
{$I LPInc/Wrappers/lp_internets.inc}

constructor TLPThread.Create(CreateSuspended: Boolean; TheSyncInfo: PSyncInfo; plugin_dir: string);
  procedure SetCurrSection(x: string); begin end;
var
  I: integer;
begin
  inherited Create(CreateSuspended, TheSyncInfo, plugin_dir);

  Parser := TLapeTokenizerString.Create('');
  Compiler := TLPCompiler.Create(Parser);
  Running := bFalse;

  InitializePascalScriptBasics(Compiler);
  ExposeGlobals(Compiler);

  Compiler['Move'].Name := 'MemMove';
  Compiler.OnFindFile := @OnFindFile;
  Compiler.OnHandleDirective := @OnHandleDirective;

  with Compiler do
  begin
    WriteLnStr := '';

    StartImporting;

    {$I LPInc/lpdefines.inc}
    {$I LPInc/lpcompile.inc}

    addGlobalFunc('procedure _write(s: string); override;', @lp_Write);
    addGlobalFunc('procedure _writeln; override;', @lp_WriteLn);
    addGlobalFunc('procedure DebugLn(s: string);', @lp_DebugLn);

    addGlobalFunc('procedure Sync(proc: Pointer);', @lp_Sync);
    addGlobalFunc('function GetCurrThreadID(): PtrUInt;', @lp_CurrThreadID);

    for I := 0 to High(VirtualKeys) do
      addGlobalVar(VirtualKeys[I].Key, Format('VK_%S', [VirtualKeys[i].Str])).isConstant := True;

    RegisterLCLClasses(Compiler);
    RegisterMMLClasses(Compiler);

    addGlobalVar('TClient', @Client, 'Client');
    addGlobalVar('TMMLSettingsSandbox', @Sett, 'Settings');

    {$I LPInc/lpexportedmethods.inc}

    EndImporting;
  end;

  ImportWrappers := TList.Create;
  ExportWrappers := TList.Create;
end;

destructor TLPThread.Destroy;
begin
  try
    if Assigned(ImportWrappers) then
    begin
      while ImportWrappers.Count <> 0 Do
      begin
        TImportClosure(ImportWrappers.First).Free;
        ImportWrappers.Delete(0)
      end;
      ImportWrappers.Free;
    end;

    if Assigned(ExportWrappers) then
    begin
      while ExportWrappers.Count <> 0 Do
      begin
        TExportClosure(ExportWrappers.First).Free;
        ExportWrappers.Delete(0)
      end;
      ExportWrappers.Free;
    end;

    if (Assigned(Compiler)) then
      Compiler.Free
    else if (Assigned(Parser)) then
      Parser.Free;
  except
    on E: Exception do
      psWriteln('Exception TLPThread.Destroy: ' + e.message);
  end;

  inherited Destroy;
end;

class function TLPThread.GetExportedMethods: TExpMethodArr;
var
  c : integer;
  CurrSection : string;

procedure SetCurrSection(str : string);
begin;
  CurrSection := Str;
end;

procedure AddGlobalFunc(DeclStr: string; Ptr: Pointer);
begin;
  if c >= 600 then
    raise exception.create('TMThread.LoadMethods: Exported more than 600 functions');

  Result[c].FuncDecl:= DeclStr;
  Result[c].FuncPtr:= Ptr;
  Result[c].Section:= CurrSection;

  Inc(c);
end;

begin
  c := 0;
  CurrSection := 'Other';
  SetLength(Result, 550);

  {$DEFINE FUNC_LIST}
  {$i LPInc/lpexportedmethods.inc}
  {$UNDEF FUNC_LIST}

  SetLength(Result, c);
end;

procedure TLPThread.SetScript(Script: string);
begin
  Parser.Doc := Script;
end;

procedure TLPThread.SetFonts(Fonts: TMFonts);
var
  i: Integer;
begin
  inherited;

  Compiler.StartImporting;

  if Assigned(Fonts) then
    for I := Fonts.Count - 1 downto 0 do
      Compiler.addGlobalVar(Fonts[I].Name, Fonts[I].Name).isConstant := True;

  Compiler.EndImporting;
end;

function TLPThread.OnFindFile(Sender: TLapeCompiler; var FileName: lpString): TLapeTokenizerBase;
begin
  Result := nil;
  if (not FindFile(FileName, [IncludeTrailingPathDelimiter(ExtractFileDir(Sender.Tokenizer.FileName)), IncludePath, ScriptPath])) then
    FileName := '';
end;

function TLPThread.OnHandleDirective(Sender: TLapeCompiler; Directive, Argument: lpString; InPeek: Boolean): Boolean;
var
  plugin_idx: integer;
begin
  Result := False;
  if (not InPeek) and (CompareText(Directive,'LOADLIB') = 0) then
  begin
    if (Argument <> '') then
    begin
      plugin_idx := PluginsGlob.LoadPlugin(Argument);
      if (plugin_idx >= 0) then
      begin
        LoadPlugin(plugin_idx);
        Result := True;
      end else
        psWriteln(Format('Your DLL %s has not been found', [Argument]))
    end else
      psWriteln('Your LoadLib directive has no params, thus cannot find the plugin');
  end;
end;

procedure TLPThread.LoadPlugin(plugidx: integer); 
var
  I: integer;
  Wrapper: TImportClosure;
  method: String;
  
  //Check if the string ends with an `Native`-keyword.
  function isNative(str:String; var Res:String): boolean;
  var len:Int32;
  begin
    Res := Trim(Str);
    Len := Length(Res);
    if (Res[len] = ';') then Dec(Len);
    if not (LowerCase(Copy(Res, len-5, 6)) = 'native') then
      Exit(False);
    Dec(len,6);
    SetLength(Res, len);
    while Res[len] in [#9,#10,#13,#32] do Dec(len);
    Result := (Res[len] = ';');
  end;
  
begin
  with PluginsGlob.MPlugins[plugidx] do
  begin
    {$IFDEF CPU32}
    if ABI < 2 then
    begin
      psWriteln('Skipping plugin due to ABI being older than version 2');
      exit; // Can't set result?
    end;
    {$ENDIF}

    if not FFILoaded() then
    begin
      writeln('Not loading plugin for lape - libffi not found');
      raise EAssertionFailed.Create('libffi is not loaded');
    end;

    Compiler.StartImporting;

    for i := 0 to TypesLen -1 do
      with Types[I] do
        Compiler.addGlobalType(TypeDef, TypeName);

    for i := 0 to MethodLen - 1 do
    begin
      if isNative(Methods[i].FuncStr, Method) then
        Compiler.addGlobalFunc(Method, Methods[i].FuncPtr)
      else begin
        Wrapper := LapeImportWrapper(Methods[i].FuncPtr, Compiler, Methods[i].FuncStr);
        Compiler.addGlobalFunc(Methods[i].FuncStr, Wrapper.func);
        ImportWrappers.Add(Wrapper);
      end;
    end;

    Compiler.EndImporting;
  end;
end;

function TLPThread.CallMethod(const Method: string; var Args: array of Variant): Variant;
begin
  if (not FFILoaded) then
    raise Exception.Create('libffi seems to be missing!');

  if (Length(Args) > 0) then
    raise Exception.Create('Lape''s CallMethod only supports procedures with no arguments.');

  with LapeExportWrapper(Compiler.Globals[Method]) do
  try
    TProcedure(func)();
  finally
    Free;
  end;
end;

procedure TLPThread.Execute;
var
  Failed: boolean;
begin
  CurrThread := Self;
  Starttime := GetTickCount;

  try
    Failed := not Compiler.Compile();
  except
    on e: lpException do
    begin
      HandleError(e.DocPos.Line, e.DocPos.Col, 0, e.OldMsg, errCompile, e.DocPos.FileName);
      Failed := True;
    end;
    on e: Exception do
    begin
      HandleError(0, 0, 0, e.message, errCompile, '');
      Failed := True;
    end;
  end;

  if (not (Failed)) then
  begin
    psWriteln('Compiled successfully in ' + IntToStr(GetTickCount - Starttime) + ' ms.');

    if CompileOnly then
      Exit;

    Running := bTrue;
    try
      RunCode(Compiler.Emitter.Code, Running);
      HandleScriptTerminates();
    except
      on e: lpException do
      begin
        HandleError(e.DocPos.Line, e.DocPos.Col, 0, e.OldMsg, errRuntime, e.DocPos.FileName);
        Failed := True;
      end;
      on e: Exception do
      begin
        HandleError(0, 0, 0, e.message, errRuntime, '');
        Failed := True;
      end;
    end;

    if (not (Failed)) then
      psWriteln('Successfully executed.')
    else
      psWriteLn('Execution failed.');
  end else
    psWriteln('Compiling failed.');
end;

procedure TLPThread.Terminate;
begin
  Running := bFalse;
end;

procedure TLPThread.HandleError(Row, Col, Pos: integer; Error: string; Typ: TErrorType; Filename: string);
begin
  if (PosEx('Runtime error: "', Error, 1) = 1) then
    Error := Copy(Error, 17, Length(Error) - 17);

  inherited HandleError(Row, Col, Pos, Error, Typ, Filename);
end;

constructor TSyncMethod.Create(Method: Pointer);
begin
  FMethod := Method
end;

procedure TSyncMethod.Call();
type
  TProc = procedure; cdecl;
begin
  TProc(FMethod)();
end;

{$ENDIF}

initialization
  PluginsGlob := TMPlugins.Create;
finalization
  //PluginsGlob.Free;
  //Its a nice idea, but it will segfault... the program is closing anyway.
end.
