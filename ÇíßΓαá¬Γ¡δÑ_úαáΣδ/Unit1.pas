////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : Fangorn Wizards Lab Extension Library v2.00
//  * Unit Name : Unit1
//  * Purpose   : Тестовый пример использования FWCobweb
//  * Author    : Александр (Rouse_) Багель
//  * Copyright : © Fangorn Wizards Lab 1998 - 2008.
//  * Version   : 1.00
//  * Home Page : http://rouse.drkb.ru
//  ****************************************************************************
//

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, ComCtrls,
  FWCobWeb, FWHelpers;

type
  TSimplePoint = class(TAbstractCobwebKnot)
  strict private
    FPosition: TPoint;
    FMouseOnItem: Boolean;
    FSelected: Boolean;
  private
    function GetPoint(const Index: Integer): Integer;
    procedure SetPoint(const Index, Value: Integer);
  protected
    procedure StoreToStream(Stream: TStream); override;
    procedure ExtractFromStream(Stream: TStream); override;
  public
    procedure Assign(const Value: TAbstractCobwebKnot); override;
    property X: Integer index 0 read GetPoint write SetPoint;
    property Y: Integer index 1 read GetPoint write SetPoint;
    property MouseOnItem: Boolean read FMouseOnItem write FMouseOnItem;
    property Selected: Boolean read FSelected write FSelected;
  end;

  TSpider = class(TAbstractCobweb)
  protected
    function GetKnotClass: TAbstractCobwebKnotClass; override;
  public
    function AddKnot(const ID: Integer): TSimplePoint; reintroduce;
    function GetKnot(const Index: Integer): TSimplePoint; reintroduce;
  end;

  TfrmCobwebDemo = class(TForm)
    PopupMenu1: TPopupMenu;
    Addpoint1: TMenuItem;
    MakeRoute1: TMenuItem;
    lvPoints: TListView;
    gbPoints: TGroupBox;
    Panel1: TPanel;
    gbRoutes: TGroupBox;
    lvRoutes: TListView;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    Edit1: TMenuItem;
    Addpoint2: TMenuItem;
    MakeRoute2: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    N2: TMenuItem;
    Clear1: TMenuItem;
    N3: TMenuItem;
    Clear2: TMenuItem;
    PopupMenu2: TPopupMenu;
    Delete1: TMenuItem;
    Saveasdefault1: TMenuItem;
    StatusBar1: TStatusBar;
    procedure Addpoint1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure MakeRoute1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Save1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Saveasdefault1Click(Sender: TObject);
  private
    Spider: TSpider;
    isMakeRoute: Boolean;
    SelectedPoint: TSimplePoint;
    procedure UpdateListViews;
  end;

var
  frmCobwebDemo: TfrmCobwebDemo;

implementation

{$R *.dfm}

{ TSimplePoint }

procedure TSimplePoint.Assign(const Value: TAbstractCobwebKnot);
begin
  inherited;
  if Value is TSimplePoint then
  begin
    X := TSimplePoint(Value).X;
    Y := TSimplePoint(Value).Y;
  end;
end;

procedure TSimplePoint.ExtractFromStream(Stream: TStream);
begin
  inherited;
  X := Stream.ReadInt32;
  Y := Stream.ReadInt32;
end;

function TSimplePoint.GetPoint(const Index: Integer): Integer;
begin
  case Index of
    0: Result := FPosition.X;
    1: Result := FPosition.Y;
  else
    Result := 0;
  end;
end;

procedure TSimplePoint.SetPoint(const Index, Value: Integer);
begin
  case Index of
    0: FPosition.X := Value;
    1: FPosition.Y := Value;
  end;
end;

procedure TSimplePoint.StoreToStream(Stream: TStream);
begin
  inherited;
  Stream.WriteInt32(X);
  Stream.WriteInt32(Y);
end;

{ TSpider }

function TSpider.AddKnot(const ID: Integer): TSimplePoint;
begin
  Result := TSimplePoint(inherited AddKnot(ID));
end;

function TSpider.GetKnot(const Index: Integer): TSimplePoint;
begin
  Result := TSimplePoint(inherited GetKnot(Index));
end;

function TSpider.GetKnotClass: TAbstractCobwebKnotClass;
begin
  Result := TSimplePoint;
end;

{ Form38 }

procedure TfrmCobwebDemo.Addpoint1Click(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  with Spider.AddKnot(Spider.KnotsCount) do
  begin
    X := P.X;
    Y := P.Y;
  end;
  Invalidate;
  UpdateListViews;
end;

procedure TfrmCobwebDemo.Clear1Click(Sender: TObject);
begin
  Spider.Clear;
  UpdateListViews;
  Invalidate;
end;

procedure TfrmCobwebDemo.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmCobwebDemo.Delete1Click(Sender: TObject);
begin
  if TListView(PopupMenu2.PopupComponent).Selected <> nil  then
  begin
    TObject(TListView(PopupMenu2.PopupComponent).Selected.Data).Free;
    UpdateListViews;
    Invalidate;
  end;
end;

procedure TfrmCobwebDemo.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
  Spider := TSpider.Create;
  DoubleBuffered := True;   
  isMakeRoute := False;
  if FileExists(ExtractFilePath(ParamStr(0)) + 'default.cbw') then
    Spider.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'default.cbw');
  UpdateListViews;
end;

procedure TfrmCobwebDemo.FormDestroy(Sender: TObject);
begin
  Spider.Free;
end;

procedure TfrmCobwebDemo.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  Knot: TSimplePoint;
  HRegion: THandle;
  Primary, Slave: TSimplePoint;
begin
  if not isMakeRoute then
  begin
    for I := 0 to Spider.KnotsCount - 1 do
    begin
      Knot := Spider.GetKnot(I);
      HRegion := CreateEllipticRgn(
        Knot.X - 9, Knot.Y - 9, Knot.X + 9, Knot.Y + 9);
      try
        if PtInRegion(HRegion, X, Y) then
        begin
          SelectedPoint := Knot;
          Break;
        end;
      finally
        DeleteObject(HRegion);
      end;
    end;
    Exit;
  end;
  Primary := nil;
  for I := 0 to Spider.KnotsCount - 1 do
  begin
    Knot := Spider.GetKnot(I);
    HRegion := CreateEllipticRgn(
      Knot.X - 9, Knot.Y - 9, Knot.X + 9, Knot.Y + 9);
    try
      if PtInRegion(HRegion, X, Y) then
        Knot.Selected := not Knot.Selected;
    finally
      DeleteObject(HRegion);
    end;
    if Knot.Selected then
    begin
      if Primary = nil then
        Primary := Knot
      else
      begin
        Slave := Knot;
        Primary.Selected := False;
        Slave.Selected := False;
        Spider.AddRoute(Primary, Slave);
        UpdateListViews;
        isMakeRoute := False;
      end;
    end;
  end;
  Invalidate;
end;

procedure TfrmCobwebDemo.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  I: Integer;
  Knot: TSimplePoint;
  HRegion: THandle;
  NeedInvalidate, MouseOnItem: Boolean;
begin
  if SelectedPoint <> nil then
  begin
    SelectedPoint.X := X;
    SelectedPoint.Y := Y;
    Invalidate;
    Exit;
  end;
  NeedInvalidate := False;
  for I := 0 to Spider.KnotsCount - 1 do
  begin
    Knot := Spider.GetKnot(I);
    HRegion := CreateEllipticRgn(
      Knot.X - 9, Knot.Y - 9, Knot.X + 9, Knot.Y + 9);
    try
      MouseOnItem := PtInRegion(HRegion, X, Y);
      if not NeedInvalidate then
        NeedInvalidate := MouseOnItem xor Knot.MouseOnItem;
      Knot.MouseOnItem := MouseOnItem;
    finally
      DeleteObject(HRegion);
    end;
  end;
  if NeedInvalidate then
    Invalidate;
end;

procedure TfrmCobwebDemo.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SelectedPoint := nil;
  UpdateListViews;
end;

procedure TfrmCobwebDemo.FormPaint(Sender: TObject);

  procedure DrawPoint(const Highligt, Selected: Boolean; const X, Y: Integer);
  begin
    if Highligt then
      Canvas.Pen.Color := clRed
    else
      Canvas.Pen.Color := clBlue;
    if isMakeRoute then
      if Selected then
        Canvas.Pen.Color := clGreen;

    Canvas.Pen.Width := 4;
    Canvas.Ellipse(X - 6, Y - 6, X + 6, Y + 6);
  end;

  procedure DrawRoute(Route: TAbstractCobwebRoute);
  var
    Primary, Slave: TSimplePoint;
  begin
    Primary := TSimplePoint(Route.PrimaryKnot);
    Slave := TSimplePoint(Route.SlaveKnot);
    Canvas.Pen.Color := clOlive;
    Canvas.Pen.Width := 4;
    Canvas.MoveTo(Primary.X, Primary.Y);
    Canvas.LineTo(Slave.X, Slave.Y);
  end;

var
  I: Integer;
  Knot: TSimplePoint;
begin
  for I := 0 to Spider.KnotsCount - 1 do
  begin
    Knot := Spider.GetKnot(I);
    DrawPoint(Knot.MouseOnItem, Knot.Selected, Knot.X, Knot.Y);
  end;
  for I := 0 to Spider.RoutesCount - 1 do
    DrawRoute(Spider.GetRoute(I));    
end;

procedure TfrmCobwebDemo.MakeRoute1Click(Sender: TObject);
begin
  isMakeRoute := True;
end;

procedure TfrmCobwebDemo.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Spider.LoadFromFile(OpenDialog1.FileName);
    Invalidate;
  end;
end;

procedure TfrmCobwebDemo.PopupMenu1Popup(Sender: TObject);
begin
  MakeRoute1.Enabled := (Spider.KnotsCount > 1) and not isMakeRoute;
  Addpoint1.Enabled := not isMakeRoute;
end;

procedure TfrmCobwebDemo.Save1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    Spider.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrmCobwebDemo.Saveasdefault1Click(Sender: TObject);
begin
  Spider.SaveToFile(ExtractFilePath(ParamStr(0)) + 'default.cbw');
end;

procedure TfrmCobwebDemo.UpdateListViews;
var
  I: Integer;
  Knot: TSimplePoint;
  Route: TAbstractCobwebRoute;
begin
  lvPoints.Items.BeginUpdate;
  try
    lvPoints.Items.Clear;
    for I := 0 to Spider.KnotsCount - 1 do
      with lvPoints.Items.Add do
      begin
        Knot := Spider.GetKnot(I);
        Caption := IntToStr(Knot.ID);
        SubItems.Add(IntToStr(Knot.X));
        SubItems.Add(IntToStr(Knot.Y));
        SubItems.Add(IntToStr(Knot.RouteCount));
        Data := Knot;
      end;
  finally
    lvPoints.Items.EndUpdate;
  end;
  lvRoutes.Items.BeginUpdate;
  try
    lvRoutes.Items.Clear;
    for I := 0 to Spider.RoutesCount - 1 do
      with lvRoutes.Items.Add do
      begin
        Route := Spider.GetRoute(I);
        Caption := IntToStr(Route.PrimaryKnot.ID);
        SubItems.Add(IntToStr(Route.SlaveKnot.ID));
        Data := Route;
      end;
  finally
    lvRoutes.Items.EndUpdate;
  end;
  StatusBar1.Panels.Items[0].Text := 'Total points count: ' +
    IntToStr(Spider.KnotsCount);
  StatusBar1.Panels.Items[1].Text := 'Total routes count: ' +
    IntToStr(Spider.RoutesCount);
end;

end.
