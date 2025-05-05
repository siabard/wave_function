program wave_function;

{$mode objfpc}{$h+}
uses
  SysUtils,
  Generics.Collections,
  wfc,
  wfc2;

  procedure DebugArrTile(arr: ArrTile);
  var
    I: integer;
  begin
    for I := Low(arr) to High(arr) do
      Write(Format('%d ', [arr[I]]));
    WriteLn;
  end;

var
  Cells: array of CCell;
  Tiles: ArrCTile;
  Width: integer;
  Height: integer;
  collapsedCount: integer;
  I: integer;
begin

  Randomize;

  Width := 20;
  Height := 20;

  SetLength(Cells, Width * Height);
  { 입력될 Tile 정보들 }
  SetLength(Tiles, 5);
  Tiles[0] := CTile.Create('ㅍ', BlankEdge);
  Tiles[1] := CTile.Create('ㅗ', UpEdge);
  Tiles[2] := CTile.Create('ㅏ', RightEdge);
  Tiles[3] := CTile.Create('ㅜ', DownEdge);
  Tiles[4] := CTile.Create('ㅓ', LeftEdge);


  { Rules }
  for I := Low(Tiles) to High(Tiles) do
    AnalyzeTile(Tiles[I], Tiles);


  { Debug Rules }
  {*
  for I := Low(Tiles) to High(Tiles) do
  begin
       WriteLn;
       WriteLn('Tile : ', I);
       Write('Up : ');
       For J := 0 To Length(Tiles[I].up) - 1 do
       begin
            Write(' ', Tiles[I].up[J]);
       end;

       WriteLn;
       Write('right : ');
       For J := 0 To Length(Tiles[I].right) - 1 do
       begin
            Write(' ', Tiles[I].right[J]);
       end;

       WriteLn;
       Write('down : ');
       For J := 0 To Length(Tiles[I].down) - 1 do
       begin
            Write(' ', Tiles[I].down[J]);
       end;

       WriteLn;
       Write('left : ');
       For J := 0 To Length(Tiles[I].left) - 1 do
       begin
            Write(' ', Tiles[I].left[J]);
       end;
  end;

  *}

  { 초기화하기 }
  SetupTiles(Cells);

  repeat
    collapsedCount := 0;
    Cells := CollapseLoop(Cells, Tiles, Width, Height);

    for I := Low(Cells) to High(Cells) do
      if Cells[I].Collapsed = True then
        Inc(collapsedCount);
    { 출력하기 part 2. }
    DisplayTiles(Cells, Tiles, Width, Height);

  until collapsedCount >= Length(Cells);


  { 정리하기 }
  for I := Low(Tiles) to High(Tiles) do
    Tiles[I].Free;

  CleanUpGrid(Cells);

end.
