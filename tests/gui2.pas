program Deform;

uses gLib2D;


var
    rot : real;
begin
    rot := 0;

    while true do
    begin
        gClear(DARKGRAY);

        gBeginQuads(nil);
            gSetColor(CHARTREUSE);
            gSetCoord(G_SCR_W / 4, G_SCR_H / 4);
            gPush();
            gSetRotation(rot);
            gSetCoordRelative(45,0);
            gAdd();
            gPop();

            gSetColor(GREEN);
            gSetCoord(3 * G_SCR_W / 4, G_SCR_H / 4);
            gPush();
            gSetRotation(2.6 * rot);
            gSetCoordRelative(30,0);
            gAdd();
            gPop();

            gSetColor(WHITE);
            gSetCoord(3 * G_SCR_W / 4, 3 * G_SCR_H / 4);
            gPush();
            gSetRotation(-rot);
            gSetCoordRelative(23,0);
            gAdd();
            gPop();

            gSetColor(SPRING_GREEN);
            gSetCoord(G_SCR_W / 4, 3 * G_SCR_H / 4);
            gPush();
            gSetRotation(-3. * rot);
            gSetCoordRelative(30,0);
            gAdd();
            gPop();
        gEnd();
(*
        gBeginLines(0);
            gSetColor(GRAY);

            gSetCoord(G_SCR_W / 4, G_SCR_H / 4);
            gAdd();
            gPush();
            gSetRotation(rot);
            gSetCoordRelative(45,0);
            gAdd();
            gPop();

            gSetCoord(3 * G_SCR_W / 4, G_SCR_H / 4);
            gAdd();
            gPush();
            gSetRotation(2. * rot);
            gSetCoordRelative(55,0);
            gAdd();
            gPop();

            gSetCoord(3 * G_SCR_W / 4, 3 * G_SCR_H / 4);
            gAdd();
            gPush();
            gSetRotation(-rot);
            gSetCoordRelative(23,0);
            gAdd();
            gPop();

            gSetCoord(G_SCR_W / 4, 3 * G_SCR_H / 4);
            gAdd();
            gPush();
            gSetRotation(-3. * rot);
            gSetCoordRelative(30,0);
            gAdd();
            gPop();
        gEnd();
*)
        gFlip();

        while (sdl_update = 1) do
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;

        rot += 1;
        if (rot > 360) then
            rot -= 360;
    end;
end.
