////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : Fangorn Wizards Lab Extension Library v2.00
//  * Unit Name : FWCobweb
//  * Purpose   : Реализация расширений стандартных классов aka Helpers.
//  * Author    : Александр (Rouse_) Багель
//  * Copyright : © Fangorn Wizards Lab 1998 - 2008.
//  * Version   : 1.00
//  * Home Page : http://rouse.drkb.ru
//  ****************************************************************************
//

unit FWHelpers;

interface

uses
  SysUtils,
  Classes;

type
  TFWStreamHelper = class Helper for TStream
  public
    procedure WriteInt32(const Value: Longint);
    function ReadInt32: Longint;
    procedure WriteInt64(const Value: Int64);
    function ReadInt64: Int64;
    procedure WriteStream(Value: TStream);
    procedure ReadStream(Value: TStream);
  end;

implementation

{ TFWStreamHelper }

function TFWStreamHelper.ReadInt32: Longint;
begin
  ReadBuffer(Result, SizeOf(Result));
end;

function TFWStreamHelper.ReadInt64: Int64;
begin
  ReadBuffer(Result, SizeOf(Result));
end;

procedure TFWStreamHelper.ReadStream(Value: TStream);
var
  L: Int64;
begin
  L := ReadInt64;
  if L > 0 then
    Value.CopyFrom(Self, L);
end;

procedure TFWStreamHelper.WriteInt32(const Value: Integer);
begin
  WriteBuffer(Value, SizeOf(Value));
end;

procedure TFWStreamHelper.WriteInt64(const Value: Int64);
begin
  WriteBuffer(Value, SizeOf(Value));
end;

procedure TFWStreamHelper.WriteStream(Value: TStream);
var
  L: Int64;
begin
  L := Value.Size;
  WriteInt64(L);
  if L > 0 then
    CopyFrom(Value, 0);
end;

end.
