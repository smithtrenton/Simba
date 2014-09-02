unit lpTIOManager_Abstract;
//Depends: TIOManager_Abstract, TObject, string, PRGB32, TPoint, TMufasaBitmap, integer, Integer, boolean, TClickType, Word, char, Boolean, TTarget

{$mode objfpc}{$H+}
{$I Simba.inc}

interface

uses
  Classes, SysUtils, lpcompiler, lptypes, lpClassHelper;

procedure Register_TIOManager_Abstract(Compiler: TLapeCompiler);

implementation

uses
  iomanager, bitmaps, graphics, MufasaTypes;

type
  PIOManager_Abstract = ^TIOManager_Abstract;
  PTarget = ^TTarget;
  PTarget_Exported = ^TTarget_Exported;
  PColor = ^TColor;
  PRetData = ^TRetData;
  PClickType = ^TClickType;

//constructor Create;
procedure TIOManager_Abstract_Init(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^ := TIOManager_Abstract.Create();
end;

//constructor Create(plugin_dir: string);
procedure TIOManager_Abstract_InitEx(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^ := TIOManager_Abstract.Create(PlpString(Params^[1])^);
end;

//function  GetError: String;
procedure TIOManager_Abstract_GetError(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PlpString(Result)^ := PIOManager_Abstract(Params^[0])^.GetError();
end;

//function  ReceivedError: Boolean;
procedure TIOManager_Abstract_ReceivedError(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PBoolean(Result)^ := PIOManager_Abstract(Params^[0])^.ReceivedError();
end;

//procedure ResetError;
procedure TIOManager_Abstract_ResetError(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.ResetError();
end;

//function SetTarget(ArrPtr: PRGB32; Size: TPoint): integer; overload;
procedure TIOManager_Abstract_SetTarget(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pinteger(Result)^ := PIOManager_Abstract(Params^[0])^.SetTarget(PPRGB32(Params^[1])^, PPoint(Params^[2])^);
end;

//function SetTarget(bmp : TMufasaBitmap) : integer; overload;
procedure TIOManager_Abstract_SetTargetEx(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pinteger(Result)^ := PIOManager_Abstract(Params^[0])^.SetTarget(PMufasaBitmap(Params^[1])^);
end;

//function SetTarget(name, initargs: string): integer; overload;
procedure TIOManager_Abstract_SetTargetExEx(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pinteger(Result)^ := PIOManager_Abstract(Params^[0])^.SetTarget(PlpString(Params^[1])^, PlpString(Params^[2])^);
end;

//function TargetValid: Boolean;
procedure TIOManager_Abstract_TargetValid(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PBoolean(Result)^ := PIOManager_Abstract(Params^[0])^.TargetValid();
end;

//procedure BitmapDestroyed(Bitmap : TMufasaBitmap);
procedure TIOManager_Abstract_BitmapDestroyed(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.BitmapDestroyed(PMufasaBitmap(Params^[1])^);
end;

//function GetColor(x,y : integer) : TColor;
procedure TIOManager_Abstract_GetColor(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PColor(Result)^ := PIOManager_Abstract(Params^[0])^.GetColor(Pinteger(Params^[1])^, Pinteger(Params^[2])^);
end;

//function ReturnData(xs, ys, width, height: Integer): TRetData;
procedure TIOManager_Abstract_ReturnData(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PRetData(Result)^ := PIOManager_Abstract(Params^[0])^.ReturnData(PInteger(Params^[1])^, PInteger(Params^[2])^, PInteger(Params^[3])^, PInteger(Params^[4])^);
end;

//procedure FreeReturnData;
procedure TIOManager_Abstract_FreeReturnData(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.FreeReturnData();
end;

//procedure GetDimensions(out W, H: Integer);
procedure TIOManager_Abstract_GetDimensions(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.GetDimensions(PInteger(Params^[1])^, PInteger(Params^[2])^);
end;

//procedure GetPosition(var Left, Top: Integer);
procedure TIOManager_Abstract_GetPosition(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.GetPosition(PInteger(Params^[1])^, PInteger(Params^[2])^);
end;

//procedure ActivateClient;
procedure TIOManager_Abstract_ActivateClient(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.ActivateClient();
end;

//function IsFrozen: boolean;
procedure TIOManager_Abstract_IsFrozen(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pboolean(Result)^ := PIOManager_Abstract(Params^[0])^.IsFrozen();
end;

//procedure SetFrozen(makefrozen: boolean);
procedure TIOManager_Abstract_SetFrozen(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.SetFrozen(Pboolean(Params^[1])^);
end;

//function MouseSetClientArea(x1, y1, x2, y2: integer): boolean;
procedure TIOManager_Abstract_MouseSetClientArea(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pboolean(Result)^ := PIOManager_Abstract(Params^[0])^.MouseSetClientArea(Pinteger(Params^[1])^, Pinteger(Params^[2])^, Pinteger(Params^[3])^, Pinteger(Params^[4])^);
end;

//procedure MouseResetClientArea;
procedure TIOManager_Abstract_MouseResetClientArea(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.MouseResetClientArea();
end;

//function ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
procedure TIOManager_Abstract_ImageSetClientArea(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pboolean(Result)^ := PIOManager_Abstract(Params^[0])^.ImageSetClientArea(Pinteger(Params^[1])^, Pinteger(Params^[2])^, Pinteger(Params^[3])^, Pinteger(Params^[4])^);
end;

//procedure ImageResetClientArea;
procedure TIOManager_Abstract_ImageResetClientArea(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.ImageResetClientArea();
end;

//procedure GetMousePos(var X, Y: Integer);
procedure TIOManager_Abstract_GetMousePos(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.GetMousePos(PInteger(Params^[1])^, PInteger(Params^[2])^);
end;

//procedure MoveMouse(X, Y: Integer);
procedure TIOManager_Abstract_MoveMouse(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.MoveMouse(PInteger(Params^[1])^, PInteger(Params^[2])^);
end;

//procedure ScrollMouse(x,y : integer; Lines : integer);
procedure TIOManager_Abstract_ScrollMouse(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.ScrollMouse(Pinteger(Params^[1])^, Pinteger(Params^[2])^, Pinteger(Params^[3])^);
end;

//procedure HoldMouse(x,y : integer; button: TClickType);
procedure TIOManager_Abstract_HoldMouse(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.HoldMouse(Pinteger(Params^[1])^, Pinteger(Params^[2])^, PClickType(Params^[3])^);
end;

//procedure ReleaseMouse(x,y : integer; button: TClickType);
procedure TIOManager_Abstract_ReleaseMouse(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.ReleaseMouse(Pinteger(Params^[1])^, Pinteger(Params^[2])^, PClickType(Params^[3])^);
end;

//procedure ClickMouse(X, Y: Integer; button: TClickType);
procedure TIOManager_Abstract_ClickMouse(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.ClickMouse(PInteger(Params^[1])^, PInteger(Params^[2])^, PClickType(Params^[3])^);
end;

//function  IsMouseButtonDown( button : TClickType) : boolean;
procedure TIOManager_Abstract_IsMouseButtonDown(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pboolean(Result)^ := PIOManager_Abstract(Params^[0])^.IsMouseButtonDown(PClickType(Params^[1])^);
end;

//procedure KeyUp(key: Word);
procedure TIOManager_Abstract_KeyUp(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.KeyUp(PWord(Params^[1])^);
end;

//procedure KeyDown(key: Word);
procedure TIOManager_Abstract_KeyDown(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.KeyDown(PWord(Params^[1])^);
end;

//procedure PressKey(key: Word);
procedure TIOManager_Abstract_PressKey(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.PressKey(PWord(Params^[1])^);
end;

//procedure SendText(text: string; keywait, keymodwait: integer);
procedure TIOManager_Abstract_SendText(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.SendText(PlpString(Params^[1])^, Pinteger(Params^[2])^, Pinteger(Params^[3])^);
end;

//function isKeyDown(key: Word): Boolean;
procedure TIOManager_Abstract_isKeyDown(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PBoolean(Result)^ := PIOManager_Abstract(Params^[0])^.isKeyDown(PWord(Params^[1])^);
end;

//function GetKeyCode(c : char) : integer;
procedure TIOManager_Abstract_GetKeyCode(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pinteger(Result)^ := PIOManager_Abstract(Params^[0])^.GetKeyCode(Pchar(Params^[1])^);
end;

//function GetImageTarget: TTarget; overload;
procedure TIOManager_Abstract_GetImageTarget(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PTarget(Result)^ := PIOManager_Abstract(Params^[0])^.GetImageTarget();
end;

//function GetKeyMouseTarget: TTarget; overload;
procedure TIOManager_Abstract_GetKeyMouseTarget(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PTarget(Result)^ := PIOManager_Abstract(Params^[0])^.GetKeyMouseTarget();
end;

//function ExportImageTarget  : TTarget_Exported; overload;
procedure TIOManager_Abstract_ExportImageTarget(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PTarget_Exported(Result)^ := PIOManager_Abstract(Params^[0])^.ExportImageTarget();
end;

//function ExportKeyMouseTarget  : TTarget_Exported; overload;
procedure TIOManager_Abstract_ExportKeyMouseTarget(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PTarget_Exported(Result)^ := PIOManager_Abstract(Params^[0])^.ExportKeyMouseTarget();
end;

//procedure GetImageTarget(var idx: integer); overload;
procedure TIOManager_Abstract_GetImageTargetEx(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.GetImageTarget(Pinteger(Params^[1])^);
end;

//procedure GetKeyMouseTarget(var idx: integer); overload;
procedure TIOManager_Abstract_GetKeyMouseTargetEx(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.GetKeyMouseTarget(Pinteger(Params^[1])^);
end;

//procedure SetImageTarget(idx: integer);
procedure TIOManager_Abstract_SetImageTarget(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.SetImageTarget(Pinteger(Params^[1])^);
end;

//procedure SetKeyMouseTarget(idx: integer);
procedure TIOManager_Abstract_SetKeyMouseTarget(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.SetKeyMouseTarget(Pinteger(Params^[1])^);
end;

//procedure FreeTarget(idx: integer);
procedure TIOManager_Abstract_FreeTarget(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.FreeTarget(Pinteger(Params^[1])^);
end;

//procedure SetState(val: Boolean);
procedure TIOManager_Abstract_SetState(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.SetState(PBoolean(Params^[1])^);
end;

//procedure Free();
procedure TIOManager_Abstract_Free(const Params: PParamArray); lape_extdecl
begin
  PIOManager_Abstract(Params^[0])^.Free();
end;

procedure Register_TIOManager_Abstract(Compiler: TLapeCompiler);
begin
  with Compiler do
  begin
    addClass('TIOManager_Abstract');

    //addGlobalFunc('procedure TIOManager_Abstract.Init(); overload;', @TIOManager_Abstract_Init);
    //addGlobalFunc('procedure TIOManager_Abstract.Init(plugin_dir: string); overload;', @TIOManager_Abstract_InitEx);
    addGlobalFunc('function TIOManager_Abstract.GetError(): String;', @TIOManager_Abstract_GetError);
    addGlobalFunc('function TIOManager_Abstract.ReceivedError(): Boolean;', @TIOManager_Abstract_ReceivedError);
    addGlobalFunc('procedure TIOManager_Abstract.ResetError();', @TIOManager_Abstract_ResetError);
    addGlobalFunc('function TIOManager_Abstract.SetTarget(ArrPtr: PRGB32; Size: TPoint): integer;', @TIOManager_Abstract_SetTarget);
    addGlobalFunc('function TIOManager_Abstract.SetTarget(bmp : TMufasaBitmap): integer; overload;', @TIOManager_Abstract_SetTargetEx);
    addGlobalFunc('function TIOManager_Abstract.SetTarget(name, initargs: string): integer; overload;', @TIOManager_Abstract_SetTargetExEx);
    addGlobalFunc('function TIOManager_Abstract.TargetValid(): Boolean;', @TIOManager_Abstract_TargetValid);
    addGlobalFunc('procedure TIOManager_Abstract.BitmapDestroyed(Bitmap : TMufasaBitmap);', @TIOManager_Abstract_BitmapDestroyed);
    addGlobalFunc('function TIOManager_Abstract.GetColor(x,y : integer): TColor;', @TIOManager_Abstract_GetColor);
    addGlobalFunc('function TIOManager_Abstract.ReturnData(xs, ys, width, height: Integer): TRetData;', @TIOManager_Abstract_ReturnData);
    addGlobalFunc('procedure TIOManager_Abstract.FreeReturnData();', @TIOManager_Abstract_FreeReturnData);
    addGlobalFunc('procedure TIOManager_Abstract.GetDimensions(out W, H: Integer);', @TIOManager_Abstract_GetDimensions);
    addGlobalFunc('procedure TIOManager_Abstract.GetPosition(var Left, Top: Integer);', @TIOManager_Abstract_GetPosition);
    addGlobalFunc('procedure TIOManager_Abstract.ActivateClient();', @TIOManager_Abstract_ActivateClient);
    addGlobalFunc('function TIOManager_Abstract.IsFrozen(): boolean;', @TIOManager_Abstract_IsFrozen);
    addGlobalFunc('procedure TIOManager_Abstract.SetFrozen(makefrozen: boolean);', @TIOManager_Abstract_SetFrozen);
    addGlobalFunc('function TIOManager_Abstract.MouseSetClientArea(x1, y1, x2, y2: integer): boolean;', @TIOManager_Abstract_MouseSetClientArea);
    addGlobalFunc('procedure TIOManager_Abstract.MouseResetClientArea();', @TIOManager_Abstract_MouseResetClientArea);
    addGlobalFunc('function TIOManager_Abstract.ImageSetClientArea(x1, y1, x2, y2: integer): boolean;', @TIOManager_Abstract_ImageSetClientArea);
    addGlobalFunc('procedure TIOManager_Abstract.ImageResetClientArea();', @TIOManager_Abstract_ImageResetClientArea);
    addGlobalFunc('procedure TIOManager_Abstract.GetMousePos(var X, Y: Integer);', @TIOManager_Abstract_GetMousePos);
    addGlobalFunc('procedure TIOManager_Abstract.MoveMouse(X, Y: Integer);', @TIOManager_Abstract_MoveMouse);
    addGlobalFunc('procedure TIOManager_Abstract.ScrollMouse(x,y : integer; Lines : integer);', @TIOManager_Abstract_ScrollMouse);
    addGlobalFunc('procedure TIOManager_Abstract.HoldMouse(x,y : integer; button: TClickType);', @TIOManager_Abstract_HoldMouse);
    addGlobalFunc('procedure TIOManager_Abstract.ReleaseMouse(x,y : integer; button: TClickType);', @TIOManager_Abstract_ReleaseMouse);
    addGlobalFunc('procedure TIOManager_Abstract.ClickMouse(X, Y: Integer; button: TClickType);', @TIOManager_Abstract_ClickMouse);
    addGlobalFunc('function TIOManager_Abstract.IsMouseButtonDown( button : TClickType): boolean;', @TIOManager_Abstract_IsMouseButtonDown);
    addGlobalFunc('procedure TIOManager_Abstract.KeyUp(key: Word);', @TIOManager_Abstract_KeyUp);
    addGlobalFunc('procedure TIOManager_Abstract.KeyDown(key: Word);', @TIOManager_Abstract_KeyDown);
    addGlobalFunc('procedure TIOManager_Abstract.PressKey(key: Word);', @TIOManager_Abstract_PressKey);
    addGlobalFunc('procedure TIOManager_Abstract.SendText(text: string; keywait, keymodwait: integer);', @TIOManager_Abstract_SendText);
    addGlobalFunc('function TIOManager_Abstract.isKeyDown(key: Word): Boolean;', @TIOManager_Abstract_isKeyDown);
    addGlobalFunc('function TIOManager_Abstract.GetKeyCode(c : char): integer;', @TIOManager_Abstract_GetKeyCode);
    addGlobalFunc('function TIOManager_Abstract.GetImageTarget(): TTarget;', @TIOManager_Abstract_GetImageTarget);
    addGlobalFunc('function TIOManager_Abstract.GetKeyMouseTarget(): TTarget;', @TIOManager_Abstract_GetKeyMouseTarget);
    addGlobalFunc('function TIOManager_Abstract.ExportImageTarget(): TTarget_Exported;', @TIOManager_Abstract_ExportImageTarget);
    addGlobalFunc('function TIOManager_Abstract.ExportKeyMouseTarget(): TTarget_Exported;', @TIOManager_Abstract_ExportKeyMouseTarget);
    addGlobalFunc('procedure TIOManager_Abstract.GetImageTarget(var idx: integer); overload;', @TIOManager_Abstract_GetImageTargetEx);
    addGlobalFunc('procedure TIOManager_Abstract.GetKeyMouseTarget(var idx: integer); overload;', @TIOManager_Abstract_GetKeyMouseTargetEx);
    addGlobalFunc('procedure TIOManager_Abstract.SetImageTarget(idx: integer);', @TIOManager_Abstract_SetImageTarget);
    addGlobalFunc('procedure TIOManager_Abstract.SetKeyMouseTarget(idx: integer);', @TIOManager_Abstract_SetKeyMouseTarget);
    addGlobalFunc('procedure TIOManager_Abstract.FreeTarget(idx: integer);', @TIOManager_Abstract_FreeTarget);
    addGlobalFunc('procedure TIOManager_Abstract.SetState(val: Boolean);', @TIOManager_Abstract_SetState);
    addGlobalFunc('procedure TIOManager_Abstract.Free();', @TIOManager_Abstract_Free);
  end;
end;

end.

