program gui;

{$mode objfpc}

uses gLib2D, SDL_TTF, Crt, sysutils, math;

CONST carte_w:integer=26;
    carte_h:integer=45;

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

Type carte = Record // L'une des 52 cartes du jeu
    couleur:string;
    valeur:integer;
end;

type carte_graph=Record
    couleur:gColor;
    texte:gImage;
end;


function convert(cart:carte;font_cartes:PTTF_Font=nil):carte_graph;
var couleur:string;
begin
    if font_cartes=nil then
        font_cartes := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.015));
    CASE cart.couleur OF
        'carreau': couleur := '[';
        'pique': couleur := '}';
        'trèfle': couleur := ']';
        'coeur': couleur := '{';
    else
        couleur := 'Z';
    end;
    convert.texte := gTextLoad(couleur+inttostr(cart.valeur),font_cartes);
    if (couleur='[') or (couleur='{') then
        convert.couleur := gLib2D.RED
    else
        convert.couleur := gLib2D.BLACK;
end;

procedure afficher_carte(x,y:real;cart:carte_graph;font_cartes:PTTF_Font;echelle:real=1);
var w,h:real;
begin
    w := carte_w*echelle;
    h := carte_h*echelle;
    gFillRect(x-w/2,y-h/2,w,h,gLib2D.WHITE);
    gDrawRect(x-w/2,y-h/2,w,h,gLib2D.BLACK);
    gBeginRects(cart.texte);
        gSetCoordMode(G_CENTER);
        gSetColor(cart.couleur);
        gSetCoord(x,y-10*echelle);
        gAdd();
    gEnd();
end;

procedure afficher_cartes(liste:array of carte_graph;font_cartes:PTTF_Font;echelle:real=1.0);
var i,j,k,interval:integer;
    x,y:real;
begin
    interval := 5;
    x := (G_SCR_H div 2)-min(19,length(liste)-2)*(carte_w+interval)*echelle/2;
    y := G_SCR_H*0.7;
    j := 0; i := 0;
    while i<length(liste) do begin
        k := i;
        while j<min(20,length(liste)-k) do begin
            //writeln('    j=',j,' i=',i);
            afficher_carte(x,y,liste[i],font_cartes,echelle);
            x += (carte_w+interval)*echelle;
            j += 1;
            i += 1;
        end;
        //writeln(min(20,length(liste)-k-1),' j=',j,' i=',i);
        j := 0;
        y += (carte_h-5)*echelle;
        x := (G_SCR_H div 2)-min(19,length(liste)-i-1)*((carte_w+interval)*echelle)/2;
        end;
    //halt;
end;


procedure afficher_joueurs(players_graph:joueurs_graph);
var i,players_nbr:integer;
Begin
    players_nbr := length(players_graph);
    for i:=0 to players_nbr-1 do begin (* Ajout des points des joueurs *)
        gBeginRects(players_graph[i].pseudo_txt); (* Ajout des pseudos *)
            gSetCoordMode(G_CENTER);
            gSetCoord(players_graph[i].x,players_graph[i].y+G_SCR_W*0.04);
            gSetColor(gLib2D.BLACK);
            gAdd();
        gEnd();
    gFillCircle(players_graph[i].x,players_graph[i].y, G_SCR_W*0.025, players_graph[i].couleur);
end;
end;


procedure launch(players_list:joueurs);
var font_noms, font_cartes : PTTF_Font;
    image : gImage;
    alpha, x, y, w, h : integer;
    i, players_nbr : integer;
    theta : real;
    players_graph : joueurs_graph;
    c:array of carte_graph;
    cs:carte;
begin
    gClear(gLib2D.BLACK);

    image := gTexLoad('tex.jpg'); (* Chargement de la texture *)
    alpha := 255; (* Alpha = 255 => opaque *)
    x := G_SCR_W div 2; (* Milieu de l'écran *)
    y := G_SCR_H div 2; (* Milieu de l'écran *)
    w := G_SCR_W; (* Largeur de l'écran *)
    h := G_SCR_H; (* Hauteur de l'écran *)
    font_noms :=  TTF_OpenFont('font_names.ttf', round(G_SCR_W*0.02));
    font_cartes := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.015));

    players_nbr := length(players_list);
    SetLength(players_graph,players_nbr);
    for i:=0 to players_nbr-1 do begin (* Initialisation des positions et des couleurs *)
        theta := 2*pi/players_nbr*i;
        players_graph[i].x := round(cos(theta)*G_SCR_W*0.44) + x;
        players_graph[i].y := round(sin(theta)*G_SCR_W*0.44) + y;
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

    SetLength(c,35);
    for i:=0 to 34 do begin
        cs.couleur := 'carreau';
        cs.valeur := 3;
        c[i] := convert(cs,font_cartes);
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

        afficher_joueurs(players_graph);

        afficher_cartes(c,font_cartes);

        try
        gFlip();
        except
            On E :Exception do begin
                writeln('4. ',E.message);
                Halt;
            end;
        end;

        while (sdl_update = 1) do
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;
    end;
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
    joueurs_list[5].pseudo := 'Leo';
    joueurs_list[5].couleur := brown;
    launch(joueurs_list);
end.
