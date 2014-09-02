{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Veneti� and Merlijn Wajer

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

    framescript for the Mufasa Macro Library
}  
unit framescript;

{$mode objfpc}{$H+}
{$I Simba.inc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, SynHighlighterPas, SynEdit, SynEditMarkupHighAll,
  mmlpsthread,ComCtrls, SynEditKeyCmds, LCLType,MufasaBase, Graphics, Controls, SynEditStrConst,
  v_ideCodeInsight, v_ideCodeParser,  SynEditHighlighter, SynPluginSyncroEdit, SynGutterBase,
  SynEditMarks, newsimbasettings;
const
   ecCodeCompletion = ecUserFirst;
   ecCodeHints = ecUserFirst + 1;
type
  TScriptState = (ss_None,ss_Running,ss_Paused,ss_Stopping);
  {
    ss_None: Means the script either hasn't been run yet, or it has ended (Succesfully or terminated)
    ss_Running: Means the script is running as we speak :-)
    ss_Paused: Means the script is currently in pause modus.
    ss_Stopping: Means we've asked PS-Script politely to stop the script (next time we press the stop button we won't be that nice).
  }

  { TScriptFrame }

  TScriptFrame = class(TFrame)
    SynEdit: TSynEdit;
    SyncEdit : TSynPluginSyncroEdit;
    procedure SynEditChange(Sender: TObject);
    procedure SynEditClickLink(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SynEditCommandProcessed(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure SynEditDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SynEditDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SynEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure SynEditKeyPress(Sender: TObject; var Key: char);
    procedure SynEditMouseLink(Sender: TObject; X, Y: Integer;
      var AllowMouseLink: Boolean);
    procedure SynEditProcessCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure SynEditProcessUserCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure SynEditSpecialLineColors(Sender: TObject; Line: integer;
      var Special: boolean; var FG, BG: TColor);
    procedure SynEditStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure SynEditGutterClick(Sender: TObject; X, Y, Line: integer; mark: TSynEditMark);
  private
    OwnerPage  : TPageControl;
    OwnerSheet : TTabSheet;//The owner TTabsheet -> For title setting
    FActiveLine: LongInt; //Debugger Hilight
    procedure SetActiveLine(Line: LongInt);
  public
    ErrorData : TErrorData;  //For threadsafestuff
    ScriptErrorLine: LongInt; //Error Hilight
    ScriptFile: string;//The path to the saved/opened file currently in the SynEdit
    StartText: string;//The text synedit holds upon start/open/save
    ScriptName: string;//The name of the currently opened/saved file.
    ScriptDefault: string;//The default script e.g. program new; begin end.
    ScriptChanged: boolean;//We need this for that little * (edited star).
    ScriptThread: TMThread;//Just one thread for now..
    FScriptState: TScriptState;//Stores the ScriptState, if you want the Run/Pause/Start buttons to change accordingly, acces through Form1
    procedure undo;
    procedure redo;
    procedure HandleErrorData;
    function GetReadOnly: Boolean;
    procedure SetReadOnly(ReadOnly: Boolean);
    procedure MakeActiveScriptFrame;
    procedure ScriptThreadTerminate(Sender: TObject);
    constructor Create(TheOwner: TComponent); override;

    procedure ReloadScript;
    property ActiveLine: LongInt read FActiveLine write SetActiveLine;
    { public declarations }
  end;

  function WordAtCaret(e: TSynEdit; var sp, ep: Integer; Start: Integer = -1; Offset: Integer = 0): string;

implementation
uses
  SimbaUnit, MufasaTypes, SynEditTypes, SynEditHighlighterFoldBase, LCLIntF, framefunctionlist;

function WordAtCaret(e: TSynEdit; var sp, ep: Integer; Start: Integer = -1; Offset: Integer = 0): string;
var
  s: string;
  l: Integer;
begin
  Result := '';
  if (Start = -1) then
    Start := e.CaretX;
  Start := Start + Offset;
  sp := Start - 1;
  ep := Start - 1;
  if (e.CaretY <= 0) or (e.CaretY > e.Lines.Count) then
    s := ''
  else
    s := e.Lines[e.CaretY - 1];
  l := Length(s);

  if (sp < 1) or (sp > l) or (not (s[sp] in ['a'..'z', 'A'..'Z', '0'..'9', '_'])) then
  begin
    Inc(sp);
    Inc(ep);
    if (sp < 1) or (sp > l) or (not (s[sp] in ['a'..'z', 'A'..'Z', '0'..'9', '_'])) then
      Exit('');
  end;

  while (sp > 1) and (sp <= l) and (s[sp - 1] in ['a'..'z', 'A'..'Z', '0'..'9', '_']) do
    Dec(sp);
  while (ep >= 1) and (ep < l) and (s[ep + 1] in ['a'..'z', 'A'..'Z', '0'..'9', '_']) do
    Inc(ep);

  if (ep > l) then
    Result := ''
  else
    Result := Copy(s, sp, ep - sp + 1);
end;

function PosToCaretXY(e : TSynEdit; pos : integer) : TPoint;
  function llen(const data: string): integer;
  begin
    result := length(Data) + length(LineEnding);
  end;

var
  loop: integer;
  count: integer;
  Lines : TStrings;
begin
  loop := 0;
  count := 0;
  Lines := e.Lines;
  while (loop < Lines.Count) and (count + llen(Lines[loop]) < pos) do
  begin
    count := count + llen(Lines[loop]);
    inc(loop);
  end;
  result.x := pos - count;
  result.y := loop + 1;
end;

{ TScriptFrame }

procedure TScriptFrame.SetActiveLine(Line: LongInt);
begin
  FActiveLine := Line;
  if ((FActiveLine < SynEdit.TopLine + 2) or (FActiveLine > SynEdit.TopLine + SynEdit.LinesInWindow - 2)) then
    SynEdit.TopLine := FActiveLine - (SynEdit.LinesInWindow div 2);
  SynEdit.CaretY := FActiveLine;
  SynEdit.CaretX := 1;
  SynEdit.Refresh;
end;

procedure TScriptFrame.SynEditChange(Sender: TObject);
begin
  ScriptErrorLine:= -1;
  if not ScriptChanged then
  begin;
    ScriptChanged:= True;
    SimbaForm.UpdateTitle;
  end;
end;

procedure TScriptFrame.SynEditClickLink(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  mp: TCodeInsight;
  ms: TMemoryStream;
  d: TDeclaration;
  sp, ep: Integer;
  s : string;
begin
  mp := TCodeInsight.Create;
  mp.FileName := ScriptFile;
  mp.OnMessage := @SimbaForm.OnCCMessage;
  mp.OnFindInclude := @SimbaForm.OnCCFindInclude;
  mp.OnLoadLibrary := @SimbaForm.OnCCLoadLibrary;

  ms := TMemoryStream.Create;
  SynEdit.Lines.SaveToStream(ms);

  try
    SynEdit.GetWordBoundsAtRowCol(SynEdit.CaretXY, sp, ep);
    if (SynEdit.CaretY <= 0) or (SynEdit.CaretY > SynEdit.Lines.Count) then
      s := ''
    else
      s := SynEdit.Lines[SynEdit.CaretY - 1];
    if ep > length(s) then //We are outside the real text, go back to the last char
       mp.Run(ms, nil, Synedit.SelStart + (Length(s) - Synedit.CaretX))
    else
       mp.Run(ms, nil, Synedit.SelStart + (ep - Synedit.CaretX) - 1);

    d := mp.FindVarBase(mp.GetExpressionAtPos);
    if (d <> nil) then
    begin
      if (TCodeInsight(d.Parser).FileName <> mp.FileName) then
      begin
        if FileExists(TCodeInsight(d.Parser).FileName) then
        begin;
          if SimbaForm.LoadScriptFile(TCodeInsight(d.Parser).FileName,true,true) then
          begin;
            SimbaForm.CurrScript.SynEdit.SelStart:= d.StartPos + 1;
            SimbaForm.CurrScript.SynEdit.SelEnd := d.StartPos + Length(TrimRight(d.RawText)) + 1;
          end;
        end
        else
          mDebugLn('Declared in "' + TCodeInsight(d.Parser).FileName  + '" at ' + IntToStr(d.StartPos));
      end else
      begin
        SynEdit.SelStart := d.StartPos + 1;
        SynEdit.SelEnd := d.StartPos + Length(TrimRight(d.RawText)) + 1;
      end;
    end;

  finally
    FreeAndNil(ms);
    FreeAndNil(mp);
  end;
end;

procedure TScriptFrame.SynEditCommandProcessed(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
var
  Command2 : TSynEditorCommand;
  s: string;
  sp, ep: Integer;
begin
  if (Command = ecChar) then
    if(AChar = '(') and (SimbaForm.ParamHint.Visible = False) and (SimbaForm.ShowParamHintAuto) then
    begin
      Command2:= ecCodeHints;
      SynEditProcessUserCommand(sender,command2,achar,nil);
    end
    else if(AChar = '.') and (SimbaForm.CodeCompletionForm.Visible = False) and (SimbaForm.ShowCodeCompletionAuto) then
    begin
      Command2:= ecCodeCompletion;
      SynEditProcessUserCommand(sender,command2,achar, Pointer(@s));
    end;

  if SimbaForm.CodeCompletionForm.Visible then
    case Command of
      ecDeleteChar, ecDeleteWord, ecDeleteEOL:
        begin
          if (SynEdit.CaretY = SimbaForm.CodeCompletionStart.y) then
          begin
            s := WordAtCaret(SynEdit, sp, ep, SimbaForm.CodeCompletionStart.x);
            if (SynEdit.CaretX >= SimbaForm.CodeCompletionStart.x) and (SynEdit.CaretX <= ep) then
            begin
              SimbaForm.CodeCompletionForm.ListBox.Filter := s;
              Exit;
            end;
          end;
          SimbaForm.CodeCompletionForm.Hide;
        end;
    end;
end;

procedure TScriptFrame.SynEditDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if Source is TFunctionListFrame then
    with TFunctionListFrame(Source).DraggingNode do
      if (Level > 0) and (Data <> nil) then
        SynEdit.InsertTextAtCaret(GetMethodName(PMethodInfo(Data)^.MethodStr, True));
end;

procedure TScriptFrame.SynEditDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Source = SimbaForm.frmFunctionList;
  if(Accept)then
  begin
    SynEdit.CaretXY := SynEdit.PixelsToLogicalPos(point(x, y));
    if(not(SimbaForm.Active))then SimbaForm.BringToFront;
    if(SimbaForm.ActiveControl <> SynEdit)then SimbaForm.ActiveControl := SynEdit;
  end;
end;

procedure TScriptFrame.SynEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_F3 then
  begin;
    SimbaForm.ActionFindNextExecute(Sender);
    key := 0;
  end
  else if key = VK_ESCAPE then
    SimbaForm.ParamHint.Hide;

  SimbaForm.CodeCompletionForm.HandleKeyDown(Sender, Key, Shift);
end;

procedure TScriptFrame.SynEditKeyPress(Sender: TObject; var Key: char);
begin
  SimbaForm.CodeCompletionForm.HandleKeyPress(Sender, Key);
end;

procedure TScriptFrame.SynEditMouseLink(Sender: TObject; X, Y: Integer;
  var AllowMouseLink: Boolean);
var
  s: string;
  Attri: TSynHighlighterAttributes;
begin
  AllowMouseLink := SynEdit.GetHighlighterAttriAtRowCol(Point(X, Y), s, Attri) and (Attri.Name = SYNS_AttrIdentifier);
end;

procedure TScriptFrame.SynEditProcessCommand(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
begin
  case Command of
    ecUndo :  begin
                Command:= ecNone;
                Self.Undo;
                Self.ScriptChanged:=True;
              end;
    ecRedo :  begin
                Command := ecNone;
                self.Redo;
                Self.ScriptChanged:=True;
              end;
  end;
end;

procedure TScriptFrame.SynEditProcessUserCommand(Sender: TObject; var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
var
  mp: TCodeInsight;
  ms: TMemoryStream;
  ItemList, InsertList, NameList: TStringList;
  sp, ep,bcc,cc,bck,posi,bracketpos,i,DotPos, BPos: Integer;
  p: TPoint;
  s, ss, Filter, sname, ProcName, TypeName: string;
  Attri: TSynHighlighterAttributes;
  d, dd: TDeclaration;
  FoundItems: TDeclarationArray;
  HasParams: Boolean;
begin
  if (Command = ecCodeCompletion) and ((not SynEdit.GetHighlighterAttriAtRowCol(Point(SynEdit.CaretX - 1, SynEdit.CaretY), s, Attri)) or
                                      ((Attri.Name <> SYNS_AttrComment) and (Attri.name <> SYNS_AttrString) and (Attri.name <> SYNS_AttrDirective))) then
  begin
    mp := TCodeInsight.Create;
    mp.FileName := ScriptFile;
    mp.OnMessage := @SimbaForm.OnCCMessage;
    mp.OnFindInclude := @SimbaForm.OnCCFindInclude;
    mp.OnLoadLibrary := @SimbaForm.OnCCLoadLibrary;

    ms := TMemoryStream.Create;
    ItemList := TStringList.Create;
    InsertList := TStringList.Create;
    InsertList.Sorted := True;

    Synedit.Lines.SaveToStream(ms);
    try
      Filter := WordAtCaret(Synedit, sp, ep);
      SimbaForm.CodeCompletionStart := Point(sp, Synedit.CaretY);

      if (SynEdit.CaretY <= 0) or (SynEdit.CaretY > SynEdit.Lines.Count) then
        s := ''
      else
        s := SynEdit.Lines[SynEdit.CaretY - 1];

      if ep > length(s) then //We are outside the real text, go back to the last char
         mp.Run(ms, nil, Synedit.SelStart + (Length(s) - Synedit.CaretX) + 1)
      else
         mp.Run(ms, nil, Synedit.SelStart + (ep - Synedit.CaretX));

      s := mp.GetExpressionAtPos;

      if (s <> '') then
      begin
        ep := LastDelimiter('.', s);
        if (ep > 0) then
          Delete(s, ep, Length(s) - ep + 1)
        else
          s := '';
      end;

      if (Data <> nil) then //If showing automatically
        if (s <> '') and ((mp.DeclarationAtPos <> nil) and ((mp.DeclarationAtPos is TciCompoundStatement) or mp.DeclarationAtPos.HasOwnerClass(TciCompoundStatement, d, True))) then
          Data := nil;
      if (Data = nil) then
      begin
        mp.FillSynCompletionProposal(ItemList, InsertList, s);
        p := SynEdit.ClientToScreen(SynEdit.RowColumnToPixels(Point(sp, SynEdit.CaretY)));
        p.y := p.y + SynEdit.LineHeight;
        SimbaForm.CodeCompletionForm.Show(p, ItemList, InsertList, Filter, SynEdit);
      end;
    finally
      FreeAndNil(ms);
      FreeAndNil(mp);
      ItemList.Free;
      InsertList.Free;
    end;
  end

  else if (Command = ecCodeHints) and ((not SynEdit.GetHighlighterAttriAtRowCol(Point(SynEdit.CaretX - 1, SynEdit.CaretY), s, Attri)) or
                                      ((Attri.Name <> SYNS_AttrComment) and (Attri.name <> SYNS_AttrString) and (Attri.name <> SYNS_AttrDirective))) then
  begin
    if SimbaForm.ParamHint.Visible = true then
      SimbaForm.ParamHint.hide;

    mp := TCodeInsight.Create;
    mp.OnMessage := @SimbaForm.OnCCMessage;
    mp.OnFindInclude := @SimbaForm.OnCCFindInclude;
    mp.OnLoadLibrary := @SimbaForm.OnCCLoadLibrary;

    ms := TMemoryStream.Create;
    synedit.Lines.SaveToStream(ms);

    try
      Synedit.GetWordBoundsAtRowCol(Synedit.CaretXY, sp, ep);
      if (SynEdit.CaretY <= 0) or (SynEdit.CaretY > SynEdit.Lines.Count) then
        s := ''
      else
        s := SynEdit.Lines[SynEdit.CaretY - 1];

      if ep > length(s) then //We are outside the real text, go back to the last char
        mp.Run(ms, nil, Synedit.SelStart + (Length(s) - Synedit.CaretX), True)
      else
        mp.Run(ms, nil, Synedit.SelStart + (ep - Synedit.CaretX) - 1, True);

      bcc := 1;bck := 0;cc := 0;
      s := mp.GetExpressionAtPos(bcc, bck, cc, ep, posi, bracketpos, true);
      if (posi = -1) then
        posi := SynEdit.SelStart + (SynEdit.CaretX - sp);
      if (bracketpos = -1) then
        bracketpos := posi + length(s);

      cc := LastDelimiter('(', s);
      if (cc > 0) then
        delete(s, cc, length(s) - cc + 1);

      if (s = '') then
        exit();

      d := mp.FindVarBase(s);
      DotPos := Pos('.', s);
      HasParams := False;

      if (d = nil) and (DotPos > 0) then // if it's a type proc.
      begin
        sName := Lowercase(Copy(s, DotPos + 1, (length(s) - DotPos) + 1));

        if (sName = '') then
          Exit();

        s := Copy(s, 0, DotPos - 1);
        NameList := TStringList.Create();
        FoundItems := mp.GetTypeProcs(NameList, s); // Return items found in the type

        // Loop though looking for a match from what is currently typed.
        for i := 0 to (NameList.Count - 1) do
        begin
          BPos := Pos('(', NameList[i]);

          if (BPos > 0) then // Has params
            if (SameText(Copy(NameList[i], 0, BPos - 1), sName)) then
            begin
              SimbaForm.ParamHint.Show(PosToCaretXY(synedit, posi), PosToCaretXY(synedit, bracketpos), TciProcedureDeclaration(FoundItems[i]), synedit, mp);
              Break; // We out
            end;
        end;

        NameList.Free();
        SetLength(FoundItems, 0);
        Exit(); // Not needed anymore. :)
      end;

      // Check FindVarBase didn't find a Proc attached to a Type.
      // Maybe Add FindVarBase with a option to not find type procs?
      if (d <> nil) then
      begin
        HasParams := False;
        ProcName := d.ShortText;

        if (d.Owner <> nil) then
          if (d.Owner.Items.Count > 0) then
          begin
            TypeName := d.Owner.Items[0].ShortText;

            if (TypeName <> ProcName) then
            begin
              if (mp.FindProcedure(ProcName, d, HasParams)) then
                if (HasParams) then
                begin
                  SimbaForm.ParamHint.Show(PosToCaretXY(synedit, posi), PosToCaretXY(synedit,bracketpos), TciProcedureDeclaration(d), synedit, mp)
                end else
                  mDebugLn('<CodeHints: No parameters expected>');

              Exit(); // We're done.
            end;
          end;
      end;

      dd := nil;

      //Find the declaration -> For example if one uses var x : TNotifyEvent..
      //You have to get the owner of x, to find the declaration of TNotifyEvent etc..
      while (d <> nil) and (d <> dd) and (d.Owner <> nil) and (not ((d is TciProcedureDeclaration) or (d.Owner is TciProcedureDeclaration))) do
      begin
        dd := d;
        d := d.Owner.Items.GetFirstItemOfClass(TciTypeKind);

        if (d <> nil) then
        begin
          d := TciTypeKind(d).GetRealType;
          if (d <> nil) and (d is TciReturnType) then
            d := d.Owner;
        end;

        if (d <> nil) and (d.Owner <> nil) and (not ((d is TciProcedureDeclaration) or (d.Owner is TciProcedureDeclaration))) then
          d := mp.FindVarBase(d.CleanText)
        else
          Break;
      end;

      //Yeah, we should have found the procedureDeclaration now!
      if (d <> nil) and (d <> dd) and (d.Owner <> nil) and ((d is TciProcedureDeclaration) or (d.Owner is TciProcedureDeclaration)) then
      begin
        if (not (d is TciProcedureDeclaration)) and (d.Owner is TciProcedureDeclaration) then
          d := d.Owner;

        if (TciProcedureDeclaration(d).Params <> '') then
          SimbaForm.ParamHint.Show(PosToCaretXY(synedit,posi), PosToCaretXY(synedit,bracketpos),
                                   TciProcedureDeclaration(d), synedit, mp)
        else
          mDebugLn('<CodeHints: no parameters expected>');
      end;
    except
      on e : exception do
        mDebugLn('CodeHints exception: ' + e.message);
      // Do not free the MP, we need to use this (Paramhint.Show uses it!!)
    end;
  end;
end;

procedure TScriptFrame.SynEditSpecialLineColors(Sender: TObject;
  Line: integer; var Special: boolean; var FG, BG: TColor);
begin
  if (Line = ScriptErrorLine) then
  begin;
    Special := True;
    BG := $50a0ff;
    FG := 0;
  end;

  if (Line = ActiveLine) then
  begin
    Special := True;
    BG := clBlue;
    FG := clWhite;
  end;
end;

procedure TScriptFrame.SynEditStatusChange(Sender: TObject; Changes: TSynStatusChanges);
var
  sp, ep: Integer;
  s: string;
begin
  {$IFDEF UpdateEditButtons}
  if scSelection in changes then
  begin;
    SimbaForm.TT_Cut.Enabled := SynEdit.SelAvail;
    SimbaForm.TT_Copy.Enabled:= SimbaForm.TT_Cut.Enabled;
    SimbaForm.TT_Paste.Enabled:= SynEdit.CanPaste;
  end;
  {$ENDIF}

  if SimbaForm.CodeCompletionForm.Visible then
    if {(scAll in Changes) or} (scTopLine in Changes) then
      SimbaForm.CodeCompletionForm.Hide
    else if (scCaretX in Changes) or (scCaretY in Changes) or (scSelection in Changes) or (scModified in Changes) then
    begin
      if (SynEdit.CaretY = SimbaForm.CodeCompletionStart.y) then
      begin
        s := WordAtCaret(SynEdit, sp, ep, SimbaForm.CodeCompletionStart.x);
        if (SynEdit.CaretX >= SimbaForm.CodeCompletionStart.x) and (SynEdit.CaretX - 1 <= ep) then
        begin
          SimbaForm.CodeCompletionForm.ListBox.Filter := s;
          Exit;
        end;
      end;

      SimbaForm.CodeCompletionForm.Hide;
    end;
end;

procedure TScriptFrame.undo;
begin
  SynEdit.Undo;
  if ScriptChanged then
    if SynEdit.Lines.Text = StartText then
    begin;
      SimbaForm.UpdateTitle;
      ScriptChanged := false;
    end;
end;

procedure TScriptFrame.redo;
begin
  SynEdit.Redo;
  if ScriptChanged then
    if SynEdit.Lines.Text = StartText then
    begin;
      SimbaForm.UpdateTitle;
      ScriptChanged := false;
    end;
end;

procedure TScriptFrame.HandleErrorData;
var
  RetStr: string;
begin
  if ErrorData.Module <> '' then
  begin;
    if not FileExists(ErrorData.Module) then
      formWriteln(Format('ERROR comes from a non-existing file (%s)',[ErrorData.Module]))
    else
    begin
      ErrorData.Module:= SetDirSeparators(ErrorData.Module);// Set it right ;-)
      SimbaForm.LoadScriptFile(ErrorData.Module,true,true);//Checks if the file is already open!
      ErrorData.Module:= '';
      SimbaForm.CurrScript.ErrorData := Self.ErrorData;
      SimbaForm.CurrScript.HandleErrorData;
      exit;
    end;
  end;

  MakeActiveScriptFrame;
  if (ErrorData.Row > 0) then
    ScriptErrorLine := ErrorData.Row;

  SynEdit.Invalidate;

  if (ErrorData.Row > 0) then
    if ErrorData.Col = -1 then
      SynEdit.SelStart := ErrorData.Position
    else
      SynEdit.LogicalCaretXY := Point(ErrorData.Col, ErrorData.Row);

  RetStr := '';
  if (Pos('error', Lowercase(ErrorData.Error)) = 0) then
    RetStr += 'Error: ';

  RetStr += ErrorData.Error;

  if (ErrorData.Row > 0) then
    RetStr += ' at line ' + IntToStr(ErrorData.Row);

  formWriteln(RetStr);
end;

procedure TScriptFrame.MakeActiveScriptFrame;
var
  i : integer;
begin
  if SimbaForm.Visible then
  for i := 0 to OwnerPage.PageCount - 1 do
    if OwnerPage.Pages[i] = OwnerSheet then
    begin;
      OwnerPage.TabIndex := i;
      if OwnerSheet.CanFocus then
        OwnerSheet.SetFocus;
      exit;
    end;
end;

procedure TScriptFrame.ScriptThreadTerminate(Sender: TObject);
begin
  FScriptState := ss_None;
  ScriptThread := nil;
  SimbaForm.RefreshTab;
end;

procedure AddKey(const SynEdit : TSynEdit; const ACmd: TSynEditorCommand; const AKey: word;const AShift: TShiftState);
begin
  with SynEdit.KeyStrokes.Add do
  begin
    Key := AKey;
    Shift := AShift;
    Command := ACmd;
  end;
end;

procedure TScriptFrame.SynEditGutterClick(Sender: TObject; X, Y, Line: integer; Mark: TSynEditMark);
var
  I, H: LongInt;
begin
  {$IFDEF USE_DEBUGGER}
  if (SimbaSettings.Interpreter._Type.Value <> interp_PS) then
    Exit;

  H := SynEdit.Marks.Count - 1;
  for I := 0 to H do
    if (SynEdit.Marks.Items[I].Line = Line) then
    begin
      SynEdit.Marks.Line[Line].Clear(True);

      try
        if (Assigned(ScriptThread)) and (ScriptThread is TPSThread) then
          with TPSThread(ScriptThread).PSScript do
            ClearBreakPoint(MainFileName, Line - 1);
      except end;

      Exit;
    end;

  Mark := TSynEditMark.Create(SynEdit);
  Mark.Line := Line;
  Mark.ImageIndex := 6;
  Mark.Visible := True;
  SynEdit.Marks.Add(Mark);

  try
    if (Assigned(ScriptThread)) and (ScriptThread is TPSThread) then
      with TPSThread(ScriptThread).PSScript do
        SetBreakPoint(MainFileName, Line - 1);
  except end;
  {$ENDIF}
end;

constructor TScriptFrame.Create(TheOwner: TComponent);
const
  AdditionalFolds:TPascalCodeFoldBlockTypes = [cfbtSlashComment,cfbtBorCommand,cfbtAnsiComment];
var
  MarkCaret : TSynEditMarkupHighlightAllCaret;
  I : TPascalCodeFoldBlockType;
begin
  inherited Create(TheOwner);
  SyncEdit := TSynPluginSyncroEdit.Create(SynEdit);
  SimbaForm.Mufasa_Image_List.GetBitmap(28,SyncEdit.GutterGlyph);

  SynEdit.Font.Assign(SimbaSettings.SourceEditor.Font.Value);

  OwnerSheet := TTabSheet(TheOwner);
  OwnerPage := TPageControl(OwnerSheet.Owner);

  SynEdit.Lines.Text := SimbaForm.DefaultScript;
  StartText:= SynEdit.Lines.text;
  ScriptDefault:= StartText;
  ScriptName:= 'Untitled';
  ScriptChanged := false;
  FScriptState:= ss_None;
  ScriptErrorLine:= -1;
  OwnerSheet.Caption:= ScriptName;

  SynEdit.Enabled := True; // For some reason we need this?

  SynEdit.Highlighter := SimbaForm.CurrHighlighter;
  SynEdit.Options := SynEdit.Options + [eoTabIndent, eoKeepCaretX, eoDragDropEditing] - [eoSmartTabs];
  SynEdit.Options2 := SynEdit.Options2 + [eoCaretSkipsSelection];
  SynEdit.Gutter.CodeFoldPart.MarkupInfo.Background:= clWhite;
  for i := low(i) to high(i) do
    if i in AdditionalFolds then
      TSynCustomFoldHighlighter(SynEdit.Highlighter).FoldConfig[ord(i)].Enabled:= True;
  SynEdit.IncrementColor.Background := $30D070;
  SynEdit.HighlightAllColor.Background:= clYellow;
  SynEdit.HighlightAllColor.Foreground:= clDefault;
  SynEdit.TabWidth := 2;
  SynEdit.BlockIndent := 2;
  MarkCaret := TSynEditMarkupHighlightAllCaret(SynEdit.MarkupByClass[TSynEditMarkupHighlightAllCaret]);
  if assigned(MarkCaret) then
  begin
    with MarkCaret.MarkupInfo do
    begin;
      Background :=$E6E6E6;
      FrameColor := clGray;
    end;
    MarkCaret.Enabled := True;
    MarkCaret.FullWord:= True;
    MarkCaret.FullWordMaxLen:= 3;
    MarkCaret.WaitTime := 1500;
    MarkCaret.IgnoreKeywords := true;
  end;
  AddKey(SynEdit,ecCodeCompletion,VK_SPACE,[ssCtrl]);
  AddKey(SynEdit,ecCodeHints,VK_SPACE,[ssCtrl,ssShift]);
end;

function TScriptFrame.GetReadOnly: Boolean;
begin
  Result := SynEdit.ReadOnly;
end;

procedure TScriptFrame.SetReadOnly(ReadOnly: Boolean);
begin
  SynEdit.ReadOnly := ReadOnly;
  SynEdit.Enabled := not ReadOnly;
  if not ReadOnly and SynEdit.CanFocus then
    SynEdit.SetFocus;
end;

procedure TScriptFrame.ReloadScript;
var
   newScript: String;
   ExternScript: TFileStream;
begin
  try
    ExternScript := TFileStream.Create(ScriptFile, fmOpenRead);
  except
    on EFOpenError do
    begin
      formWriteln('Could not open extern script :' + ScriptFile);
      exit;
    end;
  end;

  try
      SetLength(NewScript, ExternScript.Size);
      ExternScript.Read(NewScript[1], ExternScript.Size);

      SynEdit.Lines.SetText(PChar(NewScript));
      SetLength(NewScript, 0);
  finally
    ExternScript.Free;
  end;
end;

initialization
  {$R *.lfm}

end.

