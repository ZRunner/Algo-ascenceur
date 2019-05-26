program gui;

uses gLib2D, SDL, SDL_TTF;

var
    text_image : array[0..2] of gImage;
    font : PTTF_Font;

    rot : array[0..2] of real;
    i,nbr:integer;
Begin
    writeln('cookies');
    nbr := length(rot);
    gClear(DARKGRAY);
    font := TTF_OpenFont('font.ttf', 55);
    for i:=0 to nbr-1 do begin
        rot[i] := 0 + 360/nbr*i;
        text_image[i] := gTextLoad('Bonjour je m''appelle Olaf', font);
    end;

    while True do
    begin
        gClear(BLACK);

        for i:=0 to nbr-1 do begin
            gBeginRects(text_image[i]);
                gSetCoordMode(G_CENTER);
                gSetCoord(G_SCR_W div 2, G_SCR_H div 2);
                gSetColor(AZURE);
                gSetRotation(rot[i]);
                gAdd();
            gEnd();
        end;

        gFlip();

        while (sdl_update = 1) do
            if sdl_do_quit then
                exit;

        for i:=0 to nbr-1 do begin
            rot[i] += 1;
            if rot[i]>360 Then
                rot[i] -= 360;
        end;
    end;
end.
