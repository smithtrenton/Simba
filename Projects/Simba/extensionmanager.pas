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

    ExtensionManager for the Mufasa Macro Library
}
unit extensionmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,virtualextension,psextension,mufasabase,mufasatypes;

type
    TExtension = TVirtualSimbaExtension;
    (**
      TExtensionManager holds a list of TExtension, and
      has functions to easily handle hooks.
    *)

    { TExtensionManager }

    TExtensionManager = class(TObject)
    private
      FOnChange: TNotifyEvent;
      procedure SetOnchange(const AValue: TNotifyEvent);
    public
      constructor Create;
      destructor Destroy; override;
    public
      Extensions: TList;
      StartDisabled : boolean;
      property OnChange : TNotifyEvent read FOnChange write SetOnchange;
      function GetExtensionIndex(Filename : string) : integer;
      function LoadPSExtension(Filename : string; enabled : boolean=false) : boolean;
      function LoadPSExtensionsDir(Directory,ext : string) : boolean;
      function HandleHook(const HookName: String; var Args: TVariantArray; var
          Called: Boolean): Variant;
    end;

var
  ExtManager : TExtensionManager;

implementation
uses
  SimbaUnit, settingssandbox, newsimbasettings;

procedure TExtensionManager.SetOnchange(const AValue: TNotifyEvent);
var
  i : integer;
begin
  for i := 0 to Extensions.Count - 1 do
    TExtension(Extensions[i]).OnChange := AValue;;
  FOnChange:=AValue;
end;

constructor TExtensionManager.Create;
begin
  inherited Create;
  Extensions := TList.Create;
  StartDisabled := True;
end;

destructor TExtensionManager.Destroy;
var
  I, C: Integer;
begin
  C := Extensions.Count - 1;
  for I := 0 to C do
  begin
    TExtension(Extensions.Items[I]).Settings.Free;
    TExtension(Extensions.Items[I]).Free;
  end;

  Extensions.Free;
  inherited Destroy;
end;

function TExtensionManager.GetExtensionIndex(Filename: string): integer;
var
  i : integer;
begin
  for i := 0 to Extensions.Count - 1 do
    if CompareText(TExtension(Extensions[i]).Filename,filename) = 0 then
      exit(i);
  result := -1;
end;

function TExtensionManager.LoadPSExtension(Filename: string; enabled: boolean): boolean;
var
  Ext : TExtension;
begin
  if (GetExtensionIndex(filename) <> -1) then
    Exit(true);

  Result := False;
  try
    Ext := TSimbaPSExtension.Create(Filename, True);
    Extensions.Add(ext);

    ext.Settings := TMMLSettingsSandbox.Create(SimbaSettings.MMLSettings);
    ext.Settings.Prefix := format('Extensions/Extension%d/Settings/', [Extensions.Count - 1]);

    if (Enabled) or ((Lowercase(ExtractFileName(Filename)) = 'extension.sex') and (not ext.Settings.IsDirectory(''))) then
      ext.Enabled := True;

    ext.OnChange := FOnChange;
    if Assigned(FOnChange) then
      FOnChange(Self);

    Result := True;
  except
    on e : exception do
      formWritelnex(format('Error in LoadPSExtension(%s): %s',[FileName, e.message]));
  end;
end;

function GetFiles(Path, Ext: string): TstringArray;
var
  SearchRec : TSearchRec;
  c : integer;
begin
  c := 0;
  if FindFirst(Path + '*.' + ext, faAnyFile, SearchRec) = 0 then
  begin
    repeat
      inc(c);
      SetLength(Result,c);
      Result[c-1] := SearchRec.Name;
    until FindNext(SearchRec) <> 0;
    SysUtils.FindClose(SearchRec);
  end;
end;

function TExtensionManager.LoadPSExtensionsDir(Directory, ext: string): boolean;
var
  Files : TstringArray;
  i : integer;
  tempevent : TNotifyEvent;
begin
  result := false;
  if not DirectoryExists(directory) then
    exit;
  tempevent := FOnChange;
  FOnChange := nil;
  Directory := IncludeTrailingPathDelimiter(directory);
  Files := GetFiles(Directory,ext);
  for i := 0 to high(Files) do
    result := LoadPSExtension(Directory + files[i],not StartDisabled) or result;
  FOnChange := Tempevent;
  if Assigned(FOnChange) then
    FOnChange(self);
end;

// How do we return more than one result?
function TExtensionManager.HandleHook(const HookName: String; var Args:
    TVariantArray; var Called: Boolean): Variant;
var
  i, res: Integer;
begin
  Called := False;
  for i := 0 to Extensions.Count -1 do
    with TExtension(Extensions[i]) do
      if Enabled then
        if HookExists(HookName) then
        begin
          res := ExecuteHook(HookName, Args, Result);
          if res <> 0 then
            mDebugLn('Execute hook failed: Hookname: %s',[hookname])
            // Not succesfull.
          else
            Called := True;

        end;
end;

initialization
  ExtManager := TExtensionManager.Create;
  ExtManager.StartDisabled := True;
finalization
  if ExtManager <> nil then
    FreeAndNil(ExtManager);

end.

