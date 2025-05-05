unit wfc2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TEdges = array of integer;
  TIntegers = array of integer;

  { CTile }
  CTile = class;

  ArrCTile = array of CTile;

  CTile = class
  private
    FImg: string;
    FEdges: TEdges;
    { blank, up, right, down, left 순으로 열렸는지(1), 닫혔는지 (0) 여부 }
    FUp: TEdges;
    FDown: TEdges;
    FLeft: TEdges;
    FRight: TEdges;

  public
    constructor Create(AImg: string; AEdges: TEdges);
    property img: string read FImg write FImg;
    property edges: TEdges read FEdges write FEdges;
    property up: TIntegers read FUp write FUp;
    property down: TIntegers read FDown write FDown;
    property left: TIntegers read FLeft write FLeft;
    property right: TIntegers read FRight write FRight;
    procedure AddToUp(AIndex: Integer);
    procedure AddToDown(AIndex: Integer);
    procedure AddToLeft(AIndex: Integer);
    procedure AddToRight(AIndex: Integer);

  end;

  { CCell }

  CCell = class;

  ArrCell = array of CCell;

  CCell = class
  private
    FCollapsed: boolean;
    FOptions: TEdges;
  public
    constructor Create(num: integer);
    property Collapsed: boolean read FCollapsed write FCollapsed;
    property Options: TEdges read FOptions write FOptions;
    procedure AddToOption(v: Integer);
    procedure RemoveFromOption(v: Integer);
  end;

implementation

{ CTile }

constructor CTile.Create(AImg: string; AEdges: TEdges);
begin
  Self.FImg := AImg;
  Self.FEdges := AEdges;
  Self.FUp := [];
  Self.FDown := [];
  Self.FLeft := [];
  Self.FRight := [];
end;

procedure CTile.AddToUp(AIndex: Integer);
begin
  SetLength(Self.FUp, Length(Self.FUp) + 1);
  Self.FUp[High(Self.FUp)] := AIndex;
end;

procedure CTile.AddToDown(AIndex: Integer);
begin
  SetLength(Self.FDown, Length(Self.FDown) + 1);
  Self.FDown[High(Self.FDown)] := AIndex;
end;

procedure CTile.AddToLeft(AIndex: Integer);
begin
  SetLength(Self.FLeft, Length(Self.FLeft) + 1);
  Self.FLeft[High(Self.FLeft)] := AIndex;
end;

procedure CTile.AddToRight(AIndex: Integer);
begin
  SetLength(Self.FRight, Length(Self.FRight) + 1);
  Self.FRight[High(Self.FRight)] := AIndex;
end;

{ CCell }

constructor CCell.Create(num: integer);
var
  I: integer;
begin
  Self.FCollapsed := False;
  for I := 0 to num - 1 do
  begin
    Insert(I, Self.FOptions, I);
  end;
end;

procedure CCell.AddToOption(v: Integer);
begin
  SetLength(Self.FOptions, Length(Self.FOptions) + 1);
  Self.FOptions[High(Self.FOptions)] := v;
end;

procedure CCell.RemoveFromOption(v: Integer);
var
  I: Integer;
begin
     For I := Low(Self.FOptions) To High(Self.FOptions) do
     begin
       If  Self.FOptions[I] = v Then
       Begin
         Delete(Self.FOptions, I, 1);
         break;
       end;
     end;
end;

end.
