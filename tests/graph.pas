Unit graph;

{$mode objfpc}


// ---------- PUBLIC ----------- //

interface

uses gLib2D, SDL, SDL_Image, SDL_TTF, Crt, sysutils, math, classes;

type twarray = array[0..1] of integer;

(* Initialisation *)
procedure init(taille:integer); // initialiser la fenêtre, et créer la référence de l'image de fond (/!\ à appeler en premier)
procedure set_deck(cartes:cartesArray); // cartes affichées en petit en bas
procedure set_cartes_main(cartes:cartesArray); // cartes qui seront affichées en grand au milieu
procedure set_joueur(player:joueur); // le joueur en focus (par exemple celui en train de jouer)
procedure set_fps(frame_per_second:integer); // initialise le nombre d'images par seconde


(* Convertir les données *)
procedure convert_carte(var cart:carte); // Convertir une carte basique en une carte compatible avec la lib graphique
function load_players(players_list:joueursArray):joueursArray; // Convertir la liste des joueurs de base en une liste utilisable par la lib graphique
function convert_text(message:string): text_graph; // Convertir un texte
function convert_couleur(couleur:byte):color_graph; // convertir une couleur byte en couleur compatible

(* A appeler dans la boucle while *)
procedure afficher_cartes; // afficher une liste de cartes, avec possibilité de réduire/augmenter la taille
procedure afficher_joueurs(players_graph:joueursArray); // Afficher la liste des joueurs autours de la "table"
procedure afficher_background(); // Affiche l'image de fond
procedure afficher_texte(message:text_graph;couleur:color_graph); // Afficher un message
procedure refresh; // Afficher l'image
procedure focus_joueur; // Affiche le pseudo d'un joueur en haut à gauche de l'écran
procedure afficher_atout(cart:carte); // Affiche la couleur de l'atout actuel
procedure afficher_manche; // Affiche la liste des cartes jouées
procedure afficher_cadre; // affiche le cadre autours de la carte survolée par la souris


(* Partie interractivité *)
function sdl_update : integer; // Retourne 1 lorsque quelque chose bouge sur l'écran (clic etc)
function sdl_do_quit : boolean; // Si l'utilisateur ferme la fenêtre
function sdl_get_mouse_xy : twarray; // Coordonnées x - y de la souris
function sdl_get_keypressed : integer; // Si une touche du clavier est pressée, retourne sa valeur (http://www.siteduzero.com/uploads/fr/ftp/mateo21/sdlkeysym.html)
function on_click(main:boolean=False):carte; // Retourne la carte où le joueur a cliqué
function saisir_txt(message:string;limit:integer;int_seulement:boolean):string; // demande à l'utilisateur de saisir du texte


// ---------- PRIVE ------------ //

implementation

var font_noms, font_cartes, font_msg, font_atout, font_manche :PTTF_Font; // polices des textes
    _event : TSDL_Event;
    background : gImage;
    cartes_deck : cartesArray;
    cartes_main : cartesArray;
    joueur_actif : joueur;
    clic_actif : boolean;
    typing : boolean;
    text_typing : string;
    text_displayed : gImage;
    text_consigne : gImage;
    fps : integer;

procedure refresh;
begin
    gFlip;
    sleep(fps);
end;

procedure set_fps(frame_per_second:integer);
begin
    fps := round(1/frame_per_second*1000);
end;

function sdl_update : integer;
begin
    exit(SDL_PollEvent(@_event));
end;

function sdl_do_quit : boolean;
begin
    exit(_event.type_ = SDL_QUITEV);
end;

function sdl_get_mouse_xy : twarray;
begin
    sdl_get_mouse_xy[0] := _event.motion.x;
    sdl_get_mouse_xy[1] := _event.motion.y;
end;

function sdl_get_keypressed : integer;
begin
    if (_event.type_ <> SDL_KEYDOWN) then
        exit(-1);

    exit(_event.key.keysym.sym);
end;



procedure convert_carte(var cart:carte);
var couleur:string;
begin
    if font_cartes=nil then
        font_cartes := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.015));
    if font_cartes=nil then begin
        writeln('ERREUR lors du chargement de la police : ',TTF_GetError());
        halt;
    end;
    CASE cart.couleur OF
        'carreau': couleur := '[';
        'pique': couleur := '}';
        'trèfle': couleur := ']';
        'coeur': couleur := '{';
    else
        couleur := 'Z';
    end;
    cart.texte_petit := gTextLoad(couleur+inttostr(cart.valeur),font_cartes);
    cart.texte_grand := gTextLoad(couleur+inttostr(cart.valeur),font_manche);
    if (couleur='[') or (couleur='{') then
        cart.gcouleur := gLib2D.RED
    else
        cart.gcouleur := gLib2D.BLACK;
end;

function convert_text(message:string): text_graph;
begin
    convert_text := gTextLoad(message, font_msg);
end;

function convert_couleur(couleur:byte):color_graph;
begin
case couleur OF (* Transformation byte => gColor *)
    red: convert_couleur := gLib2D.RED;
    yellow: convert_couleur := gLib2D.YELLOW;
    blue: convert_couleur := gLib2D.AZURE;
    green: convert_couleur := gLib2D.GREEN;
    magenta: convert_couleur := gLib2D.MAGENTA;
    brown: convert_couleur := gLib2D.ORANGE;
    else convert_couleur := gLib2D.DARKGRAY;
end;
end;

procedure afficher_texte(message:text_graph;couleur:color_graph);
begin
    gBeginRects(message);
        gSetCoordMode(G_CENTER);
        gSetCoord(G_SCR_W div 2, G_SCR_W*0.2);
        gSetColor(couleur);
        gAdd();
    gEnd();
end;

procedure focus_joueur;
var x,y:real;
begin
    x := G_SCR_W*0.08;
    y := G_SCR_H*0.05;
    gFillRect(x-G_SCR_W*0.07,y-G_SCR_H*0.02,G_SCR_W*0.14,G_SCR_H*0.04,joueur_actif.gcouleur);
    gDrawRect(x-G_SCR_W*0.07,y-G_SCR_H*0.02,G_SCR_W*0.14,G_SCR_H*0.04,gLib2D.BLACK);
    gBeginRects(joueur_actif.pseudo_txt);
        gSetCoordMode(G_CENTER);
        gSetCoord(x,y);
        gSetColor(gLib2D.BLACK);
        gAdd();
    gEnd();
end;

procedure afficher_atout(cart:carte);
var txt,txt2:gImage;
    x,y:real;
begin
    if font_atout=nil then font_atout := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.53));
    CASE cart.couleur OF
        'carreau': txt := gTextLoad('[',font_atout);
        'pique': txt := gTextLoad('}',font_atout);
        'trèfle': txt := gTextLoad(']',font_atout);
        'coeur': txt := gTextLoad('{',font_atout);
    else
        txt := gTextLoad('Z',font_atout);
    end;
    txt2 := gTextLoad('Atout',font_noms);
    x := G_SCR_W*0.93;
    y := G_SCR_H*0.06;
    gBeginRects(txt);
        gSetCoordMode(G_CENTER);
        gSetCoord(x,y);
        if (cart.couleur='pique') or (cart.couleur='trèfle') then
            gSetColor(gLib2D.BLACK)
        else gSetColor(gLib2D.RED);
        gAdd();
    gEnd();
    gBeginRects(txt2);
        gSetCoordMode(G_CENTER);
        gSetCoord(x,y-G_SCR_H*0.035);
        gSetColor(gLib2D.BLACK);
        gAdd();
    gEnd();
end;

procedure afficher_carte(cart:carte;echelle:real=1);
var x,y,w,h:real;
begin
    x := cart.x; y:=cart.y; w:=cart.w; h:=cart.h;
    gFillRect(x-w/2,y-h/2,w,h,gLib2D.WHITE);
    gDrawRect(x-w/2,y-h/2,w,h,gLib2D.BLACK);
    if echelle<2 then
        gBeginRects(cart.texte_petit)
    else
        gBeginRects(cart.texte_grand);
    gSetCoordMode(G_CENTER);
    gSetColor(cart.gcouleur);
    gSetCoord(x,y-10*echelle);
    gAdd();
    gEnd();
end;

procedure afficher_cartes;
var i:carte;
begin
    for i in cartes_deck do
        afficher_carte(i,1.0);
end;

procedure afficher_manche;
var i:carte;
begin
    for i in cartes_main do
        afficher_carte(i,2.8);
end;


procedure afficher_joueurs(players_graph:joueursArray);
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
    gFillCircle(players_graph[i].x,players_graph[i].y, G_SCR_W*0.025, players_graph[i].gcouleur);
end;
end;


procedure saisir_txt_context();
var w,h,x,y:real;
    i:integer;
begin
    if not typing then exit;
    w := G_SCR_W*0.45; h := G_SCR_H*0.15;
    x := G_SCR_W*0.5-w/2; y := G_SCR_H*0.45-h/2;
    for i:=0 to 4 do
        gDrawRect(x-1,y-1,w+i,h+i,gLib2D.BLACK);
    gFillRect(x,y,w,h,gLib2D.WHITE);
    gBeginRects(text_displayed); (* Affichage de la réponse *)
        gSetCoordMode(G_CENTER);
        gSetCoord(x+w/2,(y+h/2)*1.07);
        gSetColor(gLib2D.BLACK);
        gAdd();
    gEnd();
    gBeginRects(text_consigne); (* Affichage de la question *)
        gSetCoordMode(G_CENTER);
        gSetCoord(x+w/2,(y+h/2)*0.95);
        gSetColor(gLib2D.BLACK);
        gAdd();
    gEnd();
end;

function saisir_txt(message:string;limit:integer;int_seulement:boolean):string;
var i:integer;
    c:char;
begin
    typing := True;
    i := -1;
    text_consigne := gTextLoad(message,font_manche);

    while (i<>13) do begin
        afficher_background;
        focus_joueur;
        if length(text_typing)=0 then
            text_displayed := gTextLoad('...',font_manche)
        else
            text_displayed := gTextLoad(text_typing,font_manche);
        saisir_txt_context;
        refresh;
        while (sdl_update = 1) do begin
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                halt;
            i := sdl_get_keypressed;
            if (length(text_typing)>=limit) then continue;
            if i<>-1 then
                c := chr(i)
            else continue;
            if c='0' then
                continue
            else if (i>255) and (i<266) then
                text_typing += intToStr(i-256)
            else if not int_seulement then
                text_typing += c;
        end;
        sleep(10);
    end;
    saisir_txt := copy(text_typing,1,limit);
    text_typing := '';
end;




procedure _cadre(c:carte;color:gColor);
begin
    gDrawRect(c.x-c.w/2-1,c.y-c.h/2-1,c.w+2,c.h+2,color);
end;

function detect_carte(main:boolean):carte;
var coo:array[0..1] of integer;
    cart:carte;
begin
    coo := sdl_get_mouse_xy;
    if main then
        for cart in cartes_main do
            if (coo[0]>cart.x-cart.w/2) and (coo[0]<cart.x+cart.w/2) and (coo[1]<cart.y+cart.h/2) and (coo[1]>cart.y-cart.h/2) then
                exit(cart);
    for cart in cartes_deck do
        if (coo[0]>cart.x-cart.w/2) and (coo[0]<cart.x+cart.w/2) and (coo[1]<cart.y+cart.h/2) and (coo[1]>cart.y-cart.h/2) then
            exit(cart);
    detect_carte.valeur := -1;
end;

procedure afficher_cadre;
var cart:carte;
begin
    cart := detect_carte(True);
    if cart.valeur>0 then
        _cadre(cart,gLib2D.VIOLET);
end;

function on_click(main:boolean=False):carte;
var cart:carte;
begin
    if (not clic_actif) and sdl_mouse_left_down then
        clic_actif := True;
    if clic_actif and sdl_mouse_left_up then begin
        cart := detect_carte(main);
        exit(cart);
        clic_actif := False;
        end;
    on_click.valeur := -1;
end;



procedure set_joueur(player:joueur);
begin
    joueur_actif := player;
end;

procedure set_deck(cartes:cartesArray);
var i,j,k,interval:integer;
    x,y:real;
begin
    SetLength(cartes_deck,length(cartes));
    interval := 7;
    x := (G_SCR_H div 2)-min(19,length(cartes)-2)*(G_SCR_W*0.033+interval)/2;
    y := G_SCR_H*0.65;
    j := 0; i := 0;
    while i<length(cartes) do begin
        k := i;
        while j<min(20,length(cartes)-k) do begin
            cartes_deck[i] := cartes[i];
            cartes_deck[i].x := x;
            cartes_deck[i].y := y;
            cartes_deck[i].w := G_SCR_W*0.036;
            cartes_deck[i].h := G_SCR_H*0.056;
            x += (G_SCR_W*0.033+interval);
            j += 1;
            i += 1;
        end;
        j := 0;
        y += (G_SCR_H*0.056-5);
        x := (G_SCR_H div 2)-min(19,length(cartes)-i-1)*(G_SCR_W*0.033+interval)/2;
    end;
end;

procedure set_cartes_main(cartes:cartesArray);
var i,interval:integer;
    x,y,w,h:real;
begin
    i := 0;
    while cartes[i].valeur>0 do i += 1;
    SetLength(cartes_main,i);
    SetLength(cartes,i);
    interval := 10;
    x := (G_SCR_H div 2)-(length(cartes)-1)*(G_SCR_W*0.1+interval)/2;
    y := G_SCR_H*0.5;
    w := G_SCR_W*0.1; h := G_SCR_H*0.156;
    for i:=0 to high(cartes) do begin
        cartes_main[i] := cartes[i];
        cartes_main[i].x := x;
        cartes_main[i].y := y;
        cartes_main[i].w := w;
        cartes_main[i].h := h;
        x += (G_SCR_W*0.1+interval);
        end;
end;



procedure init(taille:integer);
begin
    gLib2D.change_size(taille,taille);
    gClear(gLib2D.BLACK);
    background := gTexLoad('tex.jpg'); (* Chargement de la texture *)
    font_cartes := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.015));
    font_noms := TTF_OpenFont('font_names.ttf', round(G_SCR_W*0.02));
    font_msg := TTF_OpenFont('font_names.ttf', round(G_SCR_W*0.06));
    font_atout := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.053));
    font_manche := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.028));
end;

function load_players(players_list:joueursArray):joueursArray;
var i, players_nbr, x, y:integer;
    theta:real;
begin
    players_nbr := length(players_list);
    x := G_SCR_W div 2;
    y := G_SCR_H div 2;
    SetLength(load_players,players_nbr);
    for i:=0 to players_nbr-1 do begin (* Initialisation des positions et des couleurs *)
        theta := 2*pi/players_nbr*i;
        load_players[i].x := round(cos(theta)*G_SCR_W*0.44) + x;
        load_players[i].y := round(sin(theta)*G_SCR_W*0.44) + y;
        load_players[i].pseudo_txt := gTextLoad(players_list[i].pseudo,font_noms);
        load_players[i].gcouleur := convert_couleur(players_list[i].couleur);
    end;
end;

procedure afficher_background();
var x,y,w,h:integer;
begin
    x := G_SCR_W div 2; (* Milieu de l'écran *)
    y := G_SCR_H div 2; (* Milieu de l'écran *)
    w := G_SCR_W; (* Largeur de l'écran *)
    h := G_SCR_H; (* Hauteur de l'écran *)
    gBeginRects(background); (* Ajout de l'image de fond *)
        gSetCoordMode(G_CENTER);
        gSetScaleWH(w, h);
        gSetCoord(x, y);
        gAdd();
    gEnd();
end;

 begin
 TTF_Init()

end.
