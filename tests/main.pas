program gui;

uses gLib2D, SDL_TTF, Crt;

Type joueur=Record // L'un des joueurs
    pseudo:string;
    couleur:byte;
    police : PTTF_Font;
end;
Type joueurs=array of joueur;

procedure launch(players_list:joueurs);
var police : PTTF_Font;
    image : gImage;
    alpha, x, y, w, h : integer;
    i, players_nbr : integer;
    theta : real;
    players_pos : array of array [0..1] of integer;
    couleurs_liste : gColor;
    pseudos_liste : array of gImage;
begin
    gClear(gLib2D.BLACK);

    image := gTexLoad('tex.jpg'); (* Chargement de la texture *)
    alpha := 255; (* Alpha = 255 => opaque *)
    x := G_SCR_W div 2; (* Milieu de l'écran *)
    y := G_SCR_H div 2; (* Milieu de l'écran *)
    w := G_SCR_W; (* Largeur de l'écran *)
    h := G_SCR_H; (* Hauteur de l'écran *)
    police := TTF_OpenFont('font.ttf', 28);

    players_nbr := length(players_list);
    SetLength(players_pos,players_nbr);
    SetLength(pseudos_liste,players_nbr);
    for i:=0 to players_nbr-1 do begin (* Initialisation des positions et des couleurs *)
        theta := 2*pi/players_nbr*i;
        players_pos[i][0] := round(cos(theta)*380) + x;
        players_pos[i][1] := round(sin(theta)*380) + y;
        pseudos_liste[i] := gTextLoad(players_list[i].pseudo, police);
    end;

    while true do begin (* Boucle principale *)

    gClear(gLib2D.LITEGRAY);
            gBeginRects(image); (* Ajout de l'image de fond *)
                gSetCoordMode(G_CENTER);
                gSetAlpha(alpha);
                gSetScaleWH(w, h);
                gSetCoord(x, y);
                gAdd();
            gEnd();

        for i:=0 to high(players_pos) do begin (* Ajout des points des joueurs *)
            case players_list[i].couleur OF (* Transformation byte => gColor *)
                red: couleurs_liste := gLib2D.RED;
                yellow: couleurs_liste := gLib2D.YELLOW;
                blue: couleurs_liste := gLib2D.AZURE;
                green: couleurs_liste := gLib2D.GREEN;
                magenta: couleurs_liste := gLib2D.MAGENTA;
                brown: couleurs_liste := gLib2D.ORANGE;
            else couleurs_liste := gLib2D.DARKGRAY;
            end;
            gBeginRects(pseudos_liste[i]); (* Ajout des pseudos *)
                gSetCoordMode(G_CENTER);
                gSetCoord(players_pos[i][0],players_pos[i][1]+40);
                gSetColor(gLib2D.BLACK);
                gAdd();
            gEnd();
            gFillCircle(players_pos[i][0],players_pos[i][1], 30, couleurs_liste);
        end;

        gFlip();

        while (sdl_update = 1) do
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;

    end;
end;

var joueurs_list:joueurs;
begin
    SetLength(joueurs_list,5);
    joueurs_list[0].pseudo := 'Z_runner';
    joueurs_list[0].couleur := red;
    joueurs_list[1].pseudo := 'MelyMelo8';
    joueurs_list[1].couleur := YELLOW;
    joueurs_list[2].pseudo := 'Moustique';
    joueurs_list[2].couleur := blue;
    joueurs_list[3].pseudo := 'Awhikax';
    joueurs_list[3].couleur := green;
    joueurs_list[4].pseudo := 'OxXo';
    joueurs_list[4].couleur := magenta;
    launch(joueurs_list);
end.
