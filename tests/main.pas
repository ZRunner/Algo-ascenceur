program gui;

uses gLib2D, SDL_TTF, Crt;

Type joueur=Record // L'un des joueurs
    pseudo:string;
    couleur:byte;
end;
Type joueurs=array of joueur;

type joueur_graph=Record // uniquement les infos utiles
    pseudo:string;
    couleur:gColor;
    x,y:integer;
    pseudo_txt:gImage;
end;
Type joueurs_graph=array of joueur_graph;



procedure launch(players_list:joueurs);
var font_cartes, font_noms : PTTF_Font;
    image : gImage;
    alpha, x, y, w, h : integer;
    i, players_nbr : integer;
    theta : real;
    players_graph : joueurs_graph;
begin
    gClear(gLib2D.BLACK);

    image := gTexLoad('tex.jpg'); (* Chargement de la texture *)
    alpha := 255; (* Alpha = 255 => opaque *)
    x := G_SCR_W div 2; (* Milieu de l'écran *)
    y := G_SCR_H div 2; (* Milieu de l'écran *)
    w := G_SCR_W; (* Largeur de l'écran *)
    h := G_SCR_H; (* Hauteur de l'écran *)
    font_cartes := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.02));
    font_noms :=  TTF_OpenFont('font_names.ttf', round(G_SCR_W*0.03));

    players_nbr := length(players_list);
    SetLength(players_graph,players_nbr);
    for i:=0 to players_nbr-1 do begin (* Initialisation des positions et des couleurs *)
        theta := 2*pi/players_nbr*i;
        players_graph[i].x := round(cos(theta)*G_SCR_W*0.43) + x;
        players_graph[i].y := round(sin(theta)*G_SCR_W*0.43) + y;
        players_graph[i].pseudo_txt := gTextLoad(players_list[i].pseudo,font_noms);
        case players_list[i].couleur OF (* Transformation byte => gColor *)
            red: players_graph[i].couleur := gLib2D.RED;
            yellow: players_graph[i].couleur := gLib2D.YELLOW;
            blue: players_graph[i].couleur := gLib2D.AZURE;
            green: players_graph[i].couleur := gLib2D.GREEN;
            magenta: players_graph[i].couleur := gLib2D.MAGENTA;
            brown: players_graph[i].couleur := gLib2D.ORANGE;
        else players_graph[i].couleur := gLib2D.DARKGRAY;
        end;
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

        for i:=0 to players_nbr-1 do begin (* Ajout des points des joueurs *)
            gBeginRects(players_graph[i].pseudo_txt); (* Ajout des pseudos *)
                gSetCoordMode(G_CENTER);
                gSetCoord(players_graph[i].x,players_graph[i].y+G_SCR_W*0.045);
                gSetColor(gLib2D.BLACK);
                gAdd();
            gEnd();
            gFillCircle(players_graph[i].x,players_graph[i].y, G_SCR_W*0.033, players_graph[i].couleur);
        end;

        gFlip();

        while (sdl_update = 1) do
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;

    end;
end;



procedure afficher_joueurs();
begin
end;



var joueurs_list:joueurs;
begin
    SetLength(joueurs_list,6);
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
    joueurs_list[5].pseudo := '[] {}';
    joueurs_list[5].couleur := brown;
    launch(joueurs_list);
end.
