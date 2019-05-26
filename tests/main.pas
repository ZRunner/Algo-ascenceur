program gui;

uses gLib2D, SDL_TTF;

CONST players_pos : array[0..3,0..1] of integer = ((30,30),(70,30),(90,40),(200,50));

var font : PTTF_Font;
    image : gImage;
    alpha, x, y, w, h, rot : integer;
    i : integer;
begin
    image := gTexLoad('tex.jpg'); (* Texture loading *)
    alpha := 255; (* Alpha = 255 => opaque *)
    x := G_SCR_W div 2; (* Middle of screen *)
    y := G_SCR_H div 2; (* Middle of screen *)
    w := round(image^.w*1.4); (* width = image width *)
    h := round(image^.h*1.5); (* height = image height *)
    rot := 0;

    while true do begin

    gClear(AZURE);
            gBeginRects(image);
                gSetCoordMode(G_CENTER);
                gSetAlpha(alpha);
                gSetScaleWH(w, h);
                gSetCoord(x, y);
                gSetRotation(rot);
                gAdd();
            gEnd();

        for i:=0 to high(players_pos) do
            gFillCircle(players_pos[i][0],players_pos[i][1], 30, DARKGRAY);

        gFlip();

        while (sdl_update = 1) do
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;

    end;
end.
