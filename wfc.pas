unit wfc;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, wfc2;


function MinEntropies(ACells: ArrCell): integer;
function MinEntropyIndexes(ACells: ArrCell; AMin: integer): TIntegers;

procedure SetupTiles(var ACells: array of CCell; num: Integer);
procedure GenerateRules(var ATiles: array of CTile);
function PickRandomIndex(IList: TIntegers): integer;
procedure DisplayTiles(var ACells: ArrCell; ATiles: ArrCTile;
  Width: integer; Height: integer);
procedure CleanUpGrid(var ACells: array of CCell);
function CheckValid(Options: TIntegers; Valids: TIntegers): TIntegers;
function TileContainsIn(arr: TIntegers; ele: integer): boolean;
function CollapseLoop(Cells: ArrCell; Tiles: ArrCTile; Width: integer;
  Height: integer): ArrCell;
function AnalyzeTile(ATile: CTile; ATiles: array of CTile): CTile;

const
  BlankEdge: array of integer = (0, 0, 0, 0);
  UpEdge: array of integer = (1, 1, 0, 1);
  RightEdge: array of integer = (1, 1, 1, 0);
  DownEdge: array of integer = (0, 1, 1, 1);
  LeftEdge: array of integer = (1, 0, 1, 1);

implementation



function MinEntropies(ACells: ArrCell): integer;
var
  I: integer;
begin

  Result := integer.MaxValue;
  for I := Low(ACells) to High(ACells) do
  begin
    if (ACells[i].Collapsed = False) and (Length(ACells[i].Options) < Result) then
      Result := Length(ACells[I].Options);
  end;
end;

function MinEntropyIndexes(ACells: ArrCell; AMin: integer): TIntegers;
var
  I: integer;
begin
  Result := [];

  for I := Low(ACells) to High(ACells) do
  begin
    if (ACells[I].Collapsed = False) and (Length(ACells[I].Options) = AMin) then
      Insert(I, Result, 0);
  end;
end;

procedure GenerateRules(var ATiles: array of CTile);
var
  I: integer;
  ATile: CTile;
begin
  for I := Low(ATiles) to High(ATiles) do
  begin
    ATile := ATiles[I];
    ATile := AnalyzeTile(ATile, ATiles);
  end;
end;

function PickRandomIndex(IList: TIntegers): integer;
begin
  Result := IList[Random(Length(IList))];
end;

procedure SetupTiles(var ACells: array of CCell; num : Integer);
var
  I: integer;
begin
  for I := Low(ACells) to High(ACells) do
  begin
    ACells[I] := CCell.Create(num); { 총 12종류 }
  end;
end;

procedure DisplayTiles(var ACells: ArrCell; ATiles: ArrCTile;
  Width: integer; Height: integer);
var
  I, J: integer;
  Index: integer;
begin

  { Display Wave Function Collapse }
  Index := 0;
  WriteLn;

  for I := 0 to Height - 1 do
  begin
    for J := 0 to Width - 1 do
    begin

      if ACells[Index].Collapsed = True then
        Write(Format('%s', [ATiles[ACells[Index].Options[0]].img]))
      else
        Write('█');

      Inc(Index);
    end;
    WriteLn;
  end;
end;


procedure CleanUpGrid(var ACells: array of CCell);
var
  I: integer;
begin
  for I := Low(ACells) to High(ACells) do
  begin
    ACells[I].Collapsed := False;
    ACells[I].Options := [];
    ACells[I].Free;
  end;
end;

function CheckValid(Options: TIntegers; Valids: TIntegers): TIntegers;
var
  I: integer;
  ATile: integer;
begin
  {
     Valids : [blank, right]
     Options : [blank, upward, downward, right, left ]
     result : Options 에서 Valids 에 해당하는 것만 남아야한다.
  }
  Result := [];
  for I := High(Options) downto Low(Options) do
  begin
    ATile := Options[I];

    if TileContainsIn(Valids, ATile) then
      Insert(ATile, Result, 0);
  end;
end;

function TileContainsIn(arr: TIntegers; ele: integer): boolean;
var
  I: integer;
begin
  Result := False;
  for I := Low(arr) to High(arr) do
  begin
    if arr[I] = ele then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function CollapseLoop(Cells: ArrCell; Tiles: ArrCTile; Width: integer;
  Height: integer): ArrCell;
var
  I, J, K: integer;
  Index: integer;
  minimum: integer;
  FilteredIndices: TIntegers;
  PickIndex: integer;
  AIndex: integer;
  NextCells: ArrCell;
  AArrTile: TIntegers;
  ACell: CCell;
  AOptions: TIntegers;
  AOption: integer;
  ValidOptions: TIntegers;
begin

  { 랜덤으로 아이템 찾기 }
  minimum := MinEntropies(Cells);
  FilteredIndices := MinEntropyIndexes(Cells, minimum);
  PickIndex := PickRandomIndex(FilteredIndices);

  { 랜덤으로 찾은 아이템의 항목 단일화시키기 }
  { 다만 이미 가능한 Option이 없다면 blank (0) 로 강제로 설정 }
  if Length(Cells[PickIndex].Options) = 0 then
  begin
    Cells[PickIndex].Collapsed := True;
    Cells[PickIndex].AddToOption(0);
    Result := Cells;
    Exit;
  end;


  Cells[PickIndex].Collapsed := True;
  AIndex := Cells[PickIndex].Options[Random(Length(Cells[PickIndex].Options))];
  Cells[PickIndex].Options := [];
  Cells[PickIndex].AddToOption(AIndex);

  { Collapse 하기 }
  SetLength(NextCells, Width * Height);
  SetupTiles(NextCells, Length(Tiles));
  for I := 0 to Height - 1 do
    for J := 0 to Width - 1 do
    begin
      Index := (I * Width) + J;
      if Cells[Index].Collapsed = True then
      begin
        NextCells[Index] := Cells[Index];
      end
      else
      begin

        NextCells[Index].Options := [];

        AOptions := [];
        For K := 0 To Length(Tiles) do
            Insert(K, AOptions, 0);
        // AOptions := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
        { 각 Rules 은 순서대로  위(0), 왼쪽(1), 아래(2), 오른쪽(3) 이다 }
        { Look Above }

        if i > 0 then
        begin
          ACell := Cells[J + (I - 1) * Width];
          ValidOptions := [];
          for AOption in ACell.Options do
          begin
            { Valid Tile Array }
            AArrTile := Tiles[AOption].down;
            ValidOptions := Concat(ValidOptions, AArrTile);
          end;
          AOptions := CheckValid(AOptions, ValidOptions);
        end;
        { Look Below }
        if i < (Height - 1) then
        begin
          ACell := Cells[J + (I + 1) * Width];
          ValidOptions := [];
          for AOption in ACell.Options do
          begin
            { Valid Tile Array }
            AArrTile := Tiles[AOption].up;
            ValidOptions := Concat(ValidOptions, AArrTile);
          end;
          AOptions := CheckValid(AOptions, ValidOptions);
        end;
        { Look Left }
        if j > 0 then
        begin
          ACell := Cells[(J - 1) + I * Width];
          ValidOptions := [];
          for AOption in ACell.Options do
          begin
            { Valid Tile Array }
            AArrTile := Tiles[AOption].right;
            ValidOptions := Concat(ValidOptions, AArrTile);
          end;
          AOptions := CheckValid(AOptions, ValidOptions);
        end;
        { Look Right }
        if j < (Width - 1) then
        begin
          ACell := Cells[J + 1 + I * Width];
          ValidOptions := [];
          for AOption in ACell.Options do
          begin
            { Valid Tile Array }
            AArrTile := Tiles[AOption].left;
            ValidOptions := Concat(ValidOptions, AArrTile);
          end;
          AOptions := CheckValid(AOptions, ValidOptions);
        end;

        { 넣을 수 있는 항목을 기준으로 Options을 남김. }

        NextCells[Index].Options := AOptions;
        NextCells[Index].Collapsed := False;

      end;
    end;

  Result := NextCells;
end;

function AnalyzeTile(ATile: CTile; ATiles: array of CTile): CTile;
var
  I: integer;
begin
  for I := Low(ATiles) to High(ATiles) do
  begin
    // connection for up
    // Now we'll check all tiles can connect down to ATile
    if ATiles[I].edges[2] = ATile.edges[0] then
      ATile.AddToUp(I);
    // connection for right
    if ATiles[I].edges[3] = ATile.edges[1] then
      ATile.AddToRight(I);
    // connection for down
    if ATiles[I].edges[0] = ATile.edges[2] then
      ATile.AddToDown(I);
    // connection for left
    if ATiles[I].edges[1] = ATile.edges[3] then
      ATile.AddToLeft(I);

  end;
end;

end.
