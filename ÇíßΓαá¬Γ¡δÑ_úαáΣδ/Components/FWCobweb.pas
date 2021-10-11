////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : Fangorn Wizards Lab Extension Library v2.00
//  * Unit Name : FWCobweb
//  * Purpose   : Реализация абсрактного класса паутины.
//  * Author    : Александр (Rouse_) Багель
//  * Copyright : © Fangorn Wizards Lab 1998 - 2009.
//  * Version   : 1.04
//  * Home Page : http://rouse.drkb.ru
//  ****************************************************************************
//

unit FWCobweb;

interface

uses
  SysUtils,
  Classes,
  Windows,
  FWHelpers;

type

  EAbstractCobweb = class(Exception);
  EAbstractCobwebRoute = class(Exception);
  TAbstractCobwebKnot = class;
  TAbstractCobweb = class;
  TAbstractCobwebKnotClass = class of TAbstractCobwebKnot;
  TAbstractCobwebRouteClass = class of TAbstractCobwebRoute;

  // Базовый класс нотификатор
  // Необходим для своевременной синхронизации узлов и маршрутов
  // при их удалении ну и чтоб не плодить лишний код :)
  TDestroyNotifyer = class
  private
    FNotify: TNotifyEvent;
  protected
    procedure DoNotify; virtual;
  public
    destructor Destroy; override;
    property OnNotify: TNotifyEvent read FNotify write FNotify;
  end;

  // Абстрактный маршрут между двумя узлами
  // Содержит данные о двух узлах паутины (Главный и подчиненный узел)
  TAbstractCobwebRoute = class(TDestroyNotifyer)
  public type
    TRouteLoadScruct = record
      PrimaryKnotID, SlaveKnotID: Integer;
      Primary, Slave: TAbstractCobwebKnot;
    end;
    TOnLoadEvent = procedure(Sender: TObject;
      var LoadScruct: TRouteLoadScruct) of object;
  strict private
    FPrimaryKnot: TAbstractCobwebKnot;
    FSlaveKnot: TAbstractCobwebKnot;
    FID: Integer;
    FOnLoad: TOnLoadEvent;
  private
    constructor Create(Index: Integer); overload;
    procedure DoOnLoad(PrimaryKnotID, SlaveKnotID: Integer);
  protected
    procedure StoreToStream(Stream: TStream); virtual;
    procedure ExtractFromStream(Stream: TStream); virtual;
    property OnLoad: TOnLoadEvent read FOnLoad write FOnLoad;
  public
    constructor Create(Index: Integer;
      Primary, Slave: TAbstractCobwebKnot); overload; virtual;
    procedure Assign(const Value: TAbstractCobwebRoute); virtual;
    property ID: Integer read FID;
    property PrimaryKnot: TAbstractCobwebKnot read FPrimaryKnot;
    property SlaveKnot: TAbstractCobwebKnot read FSlaveKnot;
  end;

  // Абстрактный узел паутины,
  // содержит указатели на нити, присутствующие в паутине
  TAbstractCobwebKnot = class(TDestroyNotifyer)
  strict private
    FID: Integer;
    FCobwebRoutes: TList;
    FFreeRoutesOnDestroy: Boolean;
    FWaveInteration: Integer;
    FMarkedAsInRoute: Boolean;
    FLocked: Boolean;
    FMarkedAsNotInRoute: Boolean;
    function GetCount(const Index: Integer): Integer;
  protected
    procedure StoreToStream(Stream: TStream); virtual;
    procedure ExtractFromStream(Stream: TStream); virtual;
    property FreeRoutesOnDestroy: Boolean read FFreeRoutesOnDestroy write
      FFreeRoutesOnDestroy;
    // Итерация волны
    property WaveInteration: Integer read FWaveInteration write FWaveInteration;
    // Флаг, что модуль просканен и находится в списке валидных точек пути
    property MarkedAsInRoute: Boolean read FMarkedAsInRoute
      write FMarkedAsInRoute;
    // Флаг, что модуль просканен и не находится в списке валидных точек пути
    property MarkedAsNotInRoute: Boolean read FMarkedAsNotInRoute
      write FMarkedAsNotInRoute;
    property Locked: Boolean read FLocked write FLocked;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(const Value: TAbstractCobwebKnot); virtual;
    procedure AddRoute(Route: TAbstractCobwebRoute);
    procedure DelRoute(Route: TAbstractCobwebRoute);
    function GetRoute(const Index: Integer): TAbstractCobwebRoute;
    property ID: Integer read FID write FID;
    property RouteCount: Integer index 0 read GetCount;
    property OutgouingRouteCount: Integer index 1 read GetCount;
    property IncomingRouteCount: Integer index 2 read GetCount;
  end;

  TRouteDirection = (rdDown, rdUp, rdBoth);

  // Абстрактная паутина,
  // хранилище списка маршрутов и узлов
  TAbstractCobweb = class
  private const
    Header: String[3] = 'CBW';
    Version: Byte = 1;
  strict private
    FCobwebRoutes: TList;
    FCobwebKnots: TList;
    function GetCount(const Index: Integer): Integer;
    function GetIndexFromID(const ID: Integer): Integer;
  protected
    function GetRouteClass: TAbstractCobwebRouteClass; virtual;
    function GetKnotClass: TAbstractCobwebKnotClass; virtual;
    procedure OnKnotNotify(Sender: TObject); virtual;
    procedure OnRouteNotify(Sender: TObject); virtual;
    procedure OnRouteLoad(Sender: TObject;
      var LoadScruct: TAbstractCobwebRoute.TRouteLoadScruct); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(const Value: TAbstractCobweb); virtual;
    procedure MakeRoute(const Route: TAbstractCobweb;
      StartKnot, EndKnot: Integer; Direction: TRouteDirection); virtual;
    function AddRoute(Primary, Slave: TAbstractCobwebKnot):
      TAbstractCobwebRoute; virtual;
    function AddKnot(const ID: Integer): TAbstractCobwebKnot; virtual;
    procedure Clear;
    function GetKnot(const Index: Integer): TAbstractCobwebKnot; virtual;
    function GetKnotByID(const Index: Integer): TAbstractCobwebKnot; virtual;
    function GetRoute(const Index: Integer): TAbstractCobwebRoute; virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToFile(const FilePath: String);
    procedure LoadFromFile(const FilePath: String);
    property RoutesCount: Integer index 0 read GetCount;
    property KnotsCount: Integer index 1 read GetCount;
  end;

implementation

{ TDestroyNotifyer }

destructor TDestroyNotifyer.Destroy;
begin
  DoNotify;
  inherited;
end;

procedure TDestroyNotifyer.DoNotify;
begin
  if Assigned(FNotify) then
    FNotify(Self);
end;

{ TAbstractCobwebRoute }

procedure TAbstractCobwebRoute.Assign(const Value: TAbstractCobwebRoute);
begin
end;

//  Базовый конструктор класса вызываемый программистом
// =============================================================================
constructor TAbstractCobwebRoute.Create(Index: Integer;
  Primary, Slave: TAbstractCobwebKnot);
begin
  FID := Index;
  FPrimaryKnot := Primary;
  FSlaveKnot := Slave;
end;

//  Вспомогательный конструктор класса вызываемый при загрузке из потока
// =============================================================================
constructor TAbstractCobwebRoute.Create(Index: Integer);
begin
  FID := Index;
end;

//  Инициализация параметров класса при загрузке из потока
// =============================================================================
procedure TAbstractCobwebRoute.DoOnLoad(PrimaryKnotID, SlaveKnotID: Integer);
var
  LoadStruct: TRouteLoadScruct;
begin
  if Assigned(FOnLoad) then
  begin
    LoadStruct.PrimaryKnotID := PrimaryKnotID;
    LoadStruct.SlaveKnotID := SlaveKnotID;
    FOnLoad(Self, LoadStruct);
    FPrimaryKnot := LoadStruct.Primary;
    FSlaveKnot := LoadStruct.Slave;
  end
  else
    raise EAbstractCobwebRoute.Create('Ошибка инициализации маршрута.');
end;

//  Загрузка данных из потока
// =============================================================================
procedure TAbstractCobwebRoute.ExtractFromStream(Stream: TStream);
var
  PrimaryKnotID, SlaveKnotID: Integer;
begin
  // В потоке храняться только ID узлов, нам необходимо их считать
  // и взять у рутового класса указатели на данные узлы
  PrimaryKnotID := Stream.ReadInt32;
  SlaveKnotID := Stream.ReadInt32;
  DoOnLoad(PrimaryKnotID, SlaveKnotID);
end;

//  Сохранение в поток
//  Пишем только ID узлов, т.к. больше нам писать собственно нечего :)
// =============================================================================
procedure TAbstractCobwebRoute.StoreToStream(Stream: TStream);
begin
  Stream.WriteInt32(PrimaryKnot.ID);
  Stream.WriteInt32(SlaveKnot.ID);
end;

{ TAbstractCobwebKnot }

procedure TAbstractCobwebKnot.AddRoute(Route: TAbstractCobwebRoute);
begin
  FCobwebRoutes.Add(Route);
end;

procedure TAbstractCobwebKnot.Assign(const Value: TAbstractCobwebKnot);
begin
end;

constructor TAbstractCobwebKnot.Create;
begin
  FCobwebRoutes := TList.Create;
  FreeRoutesOnDestroy := True;
end;

procedure TAbstractCobwebKnot.DelRoute(Route: TAbstractCobwebRoute);
var
  Index: Integer;
begin
  Index := FCobwebRoutes.IndexOf(Route);
  if Index >= 0 then
    FCobwebRoutes.Delete(Index);
end;

destructor TAbstractCobwebKnot.Destroy;
var
  I: Integer;
begin
  // После разрушения узла - все маршруты,
  // в которых перечислен узел становятся невалидны
  // и подлежат удалению (в том случае ели они еще небыли удалены рутом)
  if FreeRoutesOnDestroy then
    for I := RouteCount - 1 downto 0 do
      GetRoute(I).Free;
  FCobwebRoutes.Free;
  inherited;
end;

procedure TAbstractCobwebKnot.ExtractFromStream(Stream: TStream);
begin
  ID := Stream.ReadInt32;
  OutputDebugString(PChar(IntToStr(ID)));
end;

function TAbstractCobwebKnot.GetCount(const Index: Integer): Integer;
var
  I: Integer;
begin
  case Index of
    0: Result := FCobwebRoutes.Count;
    1:
    begin
      Result := 0;
      for I := 0 to RouteCount - 1 do
        Inc(Result, Byte(GetRoute(I).PrimaryKnot.ID = ID));
    end;
    2:
    begin
      Result := 0;
      for I := 0 to RouteCount - 1 do
        Inc(Result, Byte(GetRoute(I).SlaveKnot.ID = ID));
    end;
  else
    Result := -1;
  end;
end;

function TAbstractCobwebKnot.GetRoute(
  const Index: Integer): TAbstractCobwebRoute;
begin
  Result := TAbstractCobwebRoute(FCobwebRoutes.Items[Index]);
end;

procedure TAbstractCobwebKnot.StoreToStream(Stream: TStream);
begin
  Stream.WriteInt32(ID);
end;

{ TAbstractCobweb }           

//  Добавление нового узла к паутине
// =============================================================================
function TAbstractCobweb.AddKnot(const ID: Integer): TAbstractCobwebKnot;
begin
  Result := GetKnotClass.Create;
  Result.ID := ID;
  Result.OnNotify := OnKnotNotify;
  FCobwebKnots.Insert(GetIndexFromID(ID), Result);
end;

//  Добавление нового маршрута к паутине
// =============================================================================
function TAbstractCobweb.AddRoute(Primary,
  Slave: TAbstractCobwebKnot): TAbstractCobwebRoute;
begin
  // Создание маршрута
  Result := GetRouteClass.Create(RoutesCount, Primary, Slave);
  // Добавляем в главный список, чтоб маршрут был доступен из главного класса
  FCobwebRoutes.Add(Result);
  // Добавляем в списки узлов
  Primary.AddRoute(Result);
  Slave.AddRoute(Result);
  // Регистрируем нотификатор удаления,
  // необходимо для корректной синхронизации узлов и маршрутов
  Result.OnNotify := OnRouteNotify;
end;

//  Полное копирование одной паутины в другую
// =============================================================================
procedure TAbstractCobweb.Assign(const Value: TAbstractCobweb);
var
  I: Integer;
  SrcKnot, DstKnot: TAbstractCobwebKnot;
  ARoute: TAbstractCobwebRoute;
begin
  Clear;
  for I := 0 to Value.KnotsCount - 1 do
  begin
    SrcKnot := Value.GetKnot(I);
    AddKnot(SrcKnot.ID).Assign(SrcKnot);
  end;
  for I := 0 to Value.RoutesCount - 1 do
  begin
    ARoute := Value.GetRoute(I);
    SrcKnot := GetKnotByID(ARoute.PrimaryKnot.ID);
    DstKnot := GetKnotByID(ARoute.SlaveKnot.ID);
    AddRoute(SrcKnot, DstKnot).Assign(ARoute);
  end;
end;

//  Полная очистка объектов класса
// =============================================================================
procedure TAbstractCobweb.Clear;
var
  I: Integer;
  DestroyNotifyer: TDestroyNotifyer;
begin
  // В принудительном режиме очистки нотификации нам не нужны
  // т.к. это только будет замедлять работу
  // а результат будет един - все объекты будут разрушены
  for I := RoutesCount - 1 downto 0 do
  begin
    DestroyNotifyer := TDestroyNotifyer(FCobwebRoutes[I]);
    DestroyNotifyer.OnNotify := nil;
    DestroyNotifyer.Free;
  end;
  FCobwebRoutes.Clear;
  for I := KnotsCount - 1 downto 0 do
  begin
    DestroyNotifyer := TDestroyNotifyer(FCobwebKnots[I]);
    // Выставляем флаг у узла, что маршруты уже удалены
    // и их не нужно освобождать принудительно в деструкторе класса 
    TAbstractCobwebKnot(DestroyNotifyer).FreeRoutesOnDestroy := False;
    DestroyNotifyer.OnNotify := nil;
    DestroyNotifyer.Free;
  end;
  FCobwebKnots.Clear;
end;

constructor TAbstractCobweb.Create;
begin
  FCobwebRoutes := TList.Create;
  FCobwebKnots := TList.Create;
end;

destructor TAbstractCobweb.Destroy;
begin
  Clear;
  FCobwebKnots.Free;
  FCobwebRoutes.Free;
  inherited;
end;

function TAbstractCobweb.GetCount(const Index: Integer): Integer;
begin
  case Index of
    0: Result := FCobwebRoutes.Count;
    1: Result := FCobwebKnots.Count;
  else
    Result := -1;
  end;
end;

//  Функция фозвращает узел по порядковому номеру
// =============================================================================
function TAbstractCobweb.GetKnot(const Index: Integer): TAbstractCobwebKnot;
begin
  Result := TAbstractCobwebKnot(FCobwebKnots.Items[Index]);
end;

//  Функция фозвращает узел по ID номеру элемента
// =============================================================================
function TAbstractCobweb.GetKnotByID(const Index: Integer): TAbstractCobwebKnot;
var
  I: Integer;
  TempKnot: TAbstractCobwebKnot;
begin
  Result := nil;
  I := GetIndexFromID(Index);
  if I >= KnotsCount then Exit;  
  TempKnot := GetKnot(I);
  if TempKnot.ID = Index then
    Result := TempKnot;
end;

//  Вспомогательный метод для наследников
//  Позволяет указывать какой класс узла создавать
// =============================================================================
function TAbstractCobweb.GetKnotClass: TAbstractCobwebKnotClass;
begin
  Result := TAbstractCobwebKnot;
end;

//  Фунция возвращает позицию элемента в которой он должен находиться,
//  или уже находится, применен дихотомический поиск
// =============================================================================
function TAbstractCobweb.GetIndexFromID(const ID: Integer): Integer;
var
  FLeft, FRight, FCurrent: Cardinal;
begin
  if KnotsCount = 0 then
  begin
    Result := 0;
    Exit;
  end;
  FLeft := 0;
  FRight := KnotsCount - 1;
  FCurrent := (FRight + FLeft) div 2;
  if GetKnot(FLeft).ID > ID then
  begin
    Result := 0;
    Exit;
  end;
  if GetKnot(FRight).ID < ID then
  begin
    Result := FRight + 1;
    Exit;
  end;
  repeat
    if GetKnot(FCurrent).ID = ID then
    begin
      Result := FCurrent;
      Exit;
    end;
    if GetKnot(FCurrent).ID < ID then
      FLeft := FCurrent
    else
      FRight := FCurrent;
    FCurrent := (FRight + FLeft) div 2;
  until FLeft = FCurrent;
  if GetKnot(FCurrent).ID < ID then
    Inc(FCurrent);
  Result := FCurrent;
end;

function TAbstractCobweb.GetRoute(const Index: Integer): TAbstractCobwebRoute;
begin
  Result := TAbstractCobwebRoute(FCobwebRoutes.Items[Index]);
end;

//  Вспомогательный метод для наследников
//  Позволяет указывать какой класс маршрута создавать
// =============================================================================
function TAbstractCobweb.GetRouteClass: TAbstractCobwebRouteClass;
begin
  Result := TAbstractCobwebRoute;
end;

procedure TAbstractCobweb.LoadFromFile(const FilePath: String);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FilePath, fmOpenRead);
  try
    F.Position := 0;
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TAbstractCobweb.LoadFromStream(Stream: TStream);
var
  AHeader: String;
  AVersion: Byte;
  I, ACount: Integer;
  SubStream: TMemoryStream;
  TempRoute: TAbstractCobwebRoute;
  UnsordedKnots: TList;
  UnsordedKnot: TAbstractCobwebKnot;
begin
  SubStream := TMemoryStream.Create;
  try
    SetLength(AHeader, 3);
    Stream.Read(AHeader[1], 3);
    if Header <> AHeader then
      raise EAbstractCobweb.Create(
        'Ошибка загрузки из потока. Неверный заголовок');
    Stream.Read(AVersion, 1);
    if Version < AVersion then
      raise EAbstractCobweb.Create(
        'Ошибка загрузки из потока. Несовместимость версий');

    Clear;
    
    ACount := Stream.ReadInt32;
    UnsordedKnots := TList.Create;
    try
      for I := 0 to ACount - 1 do
      begin
        SubStream.Clear;
        Stream.ReadStream(SubStream);
        SubStream.Position := 0;
        // Добавление узла происходит с нулевым ID,
        // реальное считывание ID происходит при вызове метода ExtractFromStream
        UnsordedKnot := GetKnotClass.Create;
        UnsordedKnot.ExtractFromStream(SubStream);
        UnsordedKnots.Add(UnsordedKnot);
      end;
      // Теперь добавляем в отсортированном по ID порядке
      for I := 0 to ACount - 1 do
      begin
        UnsordedKnot := TAbstractCobwebKnot(UnsordedKnots[I]);
        AddKnot(UnsordedKnot.ID).Assign(UnsordedKnot);
        UnsordedKnot.Free;
      end;
    finally
      UnsordedKnots.Free;
    end;

    ACount := Stream.ReadInt32;
    for I := 0 to ACount - 1 do
    begin
      SubStream.Clear;
      Stream.ReadStream(SubStream);
      // При подгрузке маршрута еще неизвестны его узлы
      // поэтому объект создается через альтернативный конструктор
      TempRoute := GetRouteClass.Create(RoutesCount);
      // А после того как ID узлов будут известны,
      // объект будет инициализированн в методе OnRouteLoad
      TempRoute.OnLoad := OnRouteLoad;
      SubStream.Position := 0;
      TempRoute.ExtractFromStream(SubStream);
    end;
  finally
    SubStream.Free;
  end;
end;

//  Процедура строит маршрут от начального до конечного узла
//  и заносит его в новую паутину
// =============================================================================
procedure TAbstractCobweb.MakeRoute(const Route: TAbstractCobweb; StartKnot,
  EndKnot: Integer; Direction: TRouteDirection);

  function MakeWave(Knot: TAbstractCobwebKnot;
    const WaveInteration: Integer): Boolean;
  var
    I: Integer;
    NextKnot, CurrRouteKnot: TAbstractCobwebKnot;
  begin
    Result := False;
    CurrRouteKnot := Route.GetKnotByID(Knot.ID);

    if CurrRouteKnot.MarkedAsInRoute then
    begin
      Result := True;
      Exit;
    end;
    CurrRouteKnot.Locked := True;
    try
      if Knot.ID = EndKnot then
      begin
        Knot.MarkedAsInRoute := True;
        Knot.WaveInteration := WaveInteration;
        Result := True;
        Exit;
      end;
      for I := 0 to Knot.RouteCount - 1 do
      begin
        case Direction of
          rdDown: NextKnot := Knot.GetRoute(I).SlaveKnot;
          rdUp: NextKnot := Knot.GetRoute(I).PrimaryKnot;
          rdBoth:
          begin
            NextKnot := Knot.GetRoute(I).PrimaryKnot;
            if NextKnot.ID = Knot.ID then
              NextKnot := Knot.GetRoute(I).SlaveKnot;
          end;
        else
          NextKnot := nil;
        end;
        if NextKnot = nil then
        begin
          Beep(0, 0);
          Continue;
        end;

        if NextKnot.ID = Knot.ID then
          Continue;
        if (NextKnot.Locked) or (CurrRouteKnot.MarkedAsInRoute) or
          (CurrRouteKnot.MarkedAsNotInRoute ) then
          Continue;

        if MakeWave(NextKnot, WaveInteration + 1) then
        begin
          Result := True;
          CurrRouteKnot.WaveInteration := WaveInteration;
          CurrRouteKnot.MarkedAsInRoute := True;
        end;
      end;
      if not CurrRouteKnot.MarkedAsInRoute then
        CurrRouteKnot.MarkedAsNotInRoute := True;
    finally
      CurrRouteKnot.Locked := False;
    end; 
  end;

var
  I: Integer;
begin
  Route.Assign(Self);
  MakeWave(Route.GetKnotByID(StartKnot), 1);
  for I := Route.KnotsCount - 1 downto 0 do
    if not Route.GetKnot(I).MarkedAsInRoute then
      Route.GetKnot(I).Free;
end;

//  Пришла нотификация о начале удаления узла
// =============================================================================
procedure TAbstractCobweb.OnKnotNotify(Sender: TObject);
var
  Index: Integer;
begin
  // Удаляем узел из корневого списка
  Index := FCobwebKnots.IndexOf(TAbstractCobwebKnot(Sender));
  if Index >= 0 then
    FCobwebKnots.Delete(Index);
end;

//  Передаем маршруту данные для его инициализации
// =============================================================================
procedure TAbstractCobweb.OnRouteLoad(Sender: TObject;
  var LoadScruct: TAbstractCobwebRoute.TRouteLoadScruct);
begin
  // Добавляем в главный список, чтоб маршрут был доступен из главного класса
  FCobwebRoutes.Add(Sender);
  // Добавляем в списки узлов
  LoadScruct.Primary := GetKnotByID(LoadScruct.PrimaryKnotID);
  LoadScruct.Primary.AddRoute(TAbstractCobwebRoute(Sender));
  LoadScruct.Slave := GetKnotByID(LoadScruct.SlaveKnotID);
  LoadScruct.Slave.AddRoute(TAbstractCobwebRoute(Sender));
  // Регистрируем нотификатор удаления,
  // необходимо для корректной синхронизации узлов и маршрутов
  TAbstractCobwebRoute(Sender).OnNotify := OnRouteNotify;
end;

//  Пришла нотификация о начале удаления маршрута
// =============================================================================
procedure TAbstractCobweb.OnRouteNotify(Sender: TObject);
var
  Route: TAbstractCobwebRoute;
  Index: Integer;
begin
  Route := TAbstractCobwebRoute(Sender);
  // Удаляем маршрут из списков узлов
  Route.PrimaryKnot.DelRoute(Route);
  Route.SlaveKnot.DelRoute(Route);
  // Удаляем маршрут из корневого списка
  Index := FCobwebRoutes.IndexOf(Route);
  if Index >= 0 then
    FCobwebRoutes.Delete(Index);
end;

procedure TAbstractCobweb.SaveToFile(const FilePath: String);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FilePath, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TAbstractCobweb.SaveToStream(Stream: TStream);
var
  I, ACount: Integer;
  SubStream: TMemoryStream;
begin
  SubStream := TMemoryStream.Create;
  try
    Stream.Write(Header[1], 3);
    Stream.Write(Version, 1);
    ACount := KnotsCount;
    Stream.WriteInt32(ACount);
    for I := 0 to ACount - 1 do
    begin
      SubStream.Clear;
      GetKnot(I).StoreToStream(SubStream);
      Stream.WriteStream(SubStream);
    end;
    ACount := RoutesCount;
    Stream.WriteInt32(ACount);
    for I := 0 to ACount - 1 do
    begin
      SubStream.Clear;
      TAbstractCobwebRoute(FCobwebRoutes.Items[I]).StoreToStream(SubStream);
      Stream.WriteStream(SubStream);
    end;
  finally
    SubStream.Free;
  end;
end;

end.
