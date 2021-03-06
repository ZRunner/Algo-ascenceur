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
procedure load_players(var players_list:joueursArray); // Convertir la liste des joueurs de base en une liste utilisable par la lib graphique
function convert_text(message:string): text_graph; // Convertir un texte
function convert_couleur(couleur:byte):color_graph; // convertir une couleur byte en couleur compatible

(* A appeler dans la boucle while *)
procedure afficher_cartes; // afficher une liste de cartes, avec possibilité de réduire/augmenter la taille
procedure afficher_joueurs; // Afficher la liste des joueurs autours de la "table"
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
procedure afficher_score(liste:joueursArray;temps:integer);

// ---------- PRIVE ------------ //

implementation

var font_noms, font_cartes, font_msg, font_atout, font_manche, font_score :PTTF_Font; // polices des textes
    _event : TSDL_Event;
    background : gImage;
    cartes_deck : cartesArray;
    cartes_main : cartesArray;
    liste_joueurs : joueursArray;
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


function convert_valeur(valeur:integer):string;
Begin
    if valeur<11 then Exit(IntToStr(valeur));
    Case valeur of
        11: convert_valeur := 'V';
        12: convert_valeur := 'Q';
        13: convert_valeur := 'K';
        14: convert_valeur := 'A';
    end;
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
    if (couleur='[') or (couleur='{') then
        cart.gcouleur := gLib2D.RED
    else
        cart.gcouleur := gLib2D.BLACK;
    couleur := couleur + convert_valeur(cart.valeur);
    cart.texte_petit := gTextLoad(couleur,font_cartes);
    cart.texte_grand := gTextLoad(couleur,font_manche);

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

procedure afficher_score(liste:joueursArray;temps:integer);
var x,y,w,h:real;
    i:integer;
begin
    afficher_background;
    w := G_SCR_W*0.75; h := G_SCR_H*0.6;
    x := G_SCR_W*0.5-w*0.5; y := G_SCR_H*0.5-h*0.6;
    gFillRect(x,y,w,h,gLib2D.WHITE);
    gDrawRect(x-1,y-1,w+4,h+4,gLib2D.GRAY);
    gDrawRect(x-1,y-1,w+3,h+3,gLib2D.DARKGRAY);
    gDrawRect(x-1,y-1,w+2,h+2,gLib2D.BLACK);
    gBeginRects(gTextLoad('SCORES :',font_score));
        gSetCoordMode(G_CENTER);
        gSetCoord(G_SCR_W*0.5,G_SCR_H*0.2);
        gSetColor(gLib2D.BLACK);
        gAdd();
    gEnd();
    for i:=0 to high(liste) do begin
        gBeginRects(gTextLoad(liste[i].pseudo+' : '+intToStr(liste[i].point),font_score));
            gSetCoordMode(G_CENTER);
            gSetCoord(G_SCR_W*0.5,G_SCR_H*(0.3+i*0.07));
            gSetColor(gLib2D.BLACK);
            gAdd();
        gEnd();
    end;
    refresh;
    sleep(temps*1000);
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
    x := cart.x*G_SCR_W; y:=cart.y*G_SCR_H; w:=cart.w*G_SCR_W; h:=cart.h*G_SCR_H;
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


procedure afficher_joueurs();
var i,players_nbr:integer;
Begin
    players_nbr := length(liste_joueurs);
    for i:=0 to players_nbr-1 do begin (* Ajout des points des joueurs *)
        gBeginRects(liste_joueurs[i].pseudo_txt); (* Ajout des pseudos *)
            gSetCoordMode(G_CENTER);
            gSetCoord(liste_joueurs[i].x,liste_joueurs[i].y+G_SCR_W*0.04);
            gSetColor(gLib2D.BLACK);
            gAdd();
        gEnd();
    gFillCircle(liste_joueurs[i].x,liste_joueurs[i].y, G_SCR_W*0.025, liste_joueurs[i].gcouleur);
end;
end;


procedure saisir_txt_context(longueur:integer);
var w,h,x,y:real;
    i:integer;
begin
    if not typing then exit;
    w := G_SCR_W*0.02*(longueur+1); h := G_SCR_H*0.17;
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
        gSetCoord(x+w/2,(y+h/2)*0.9);
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

    while (i<>13) and (i<>271) do begin
        afficher_background;
        focus_joueur;
        if length(text_typing)=0 then
            text_displayed := gTextLoad('...',font_manche)
        else
            text_displayed := gTextLoad(text_typing,font_manche);
        saisir_txt_context(length(message));
        refresh;
        while (sdl_update = 1) do begin
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                halt;
            i := sdl_get_keypressed;

            if i>-1 then writeln('i: ',i);
            if ((i>96) and (i<123)) or ((i>255) and (i<266)) or (i=13) or (i=271) or (i=8) then
                c := chr(i)
            else continue;
            if (c='0') then
                continue
            else if i=8 then
                SetLength(text_typing, max(0,Length(text_typing) - 1))
            else if (length(text_typing)>=limit) then
                continue
            else if (i>255) and (i<266) then
                text_typing += intToStr(i-256)
            else if not int_seulement then
                text_typing += c;
            writeln('txt: ',text_typing);
        end;
        sleep(10);
    end;
    saisir_txt := copy(text_typing,1,limit);
    text_typing := '';
end;




procedure _cadre(c:carte;color:gColor);
begin
    gDrawRect(c.x*G_SCR_W - c.w/2*G_SCR_W - 1 , c.y*G_SCR_W - c.h/2*G_SCR_W - 1 , c.w*G_SCR_W+2 , c.h*G_SCR_W+2,color);
end;

function detect_carte(main:boolean):carte;
var coo:array[0..1] of integer;
    cart:carte;
begin
    coo := sdl_get_mouse_xy;
    if main then
        for cart in cartes_main do
            if (coo[0]>(cart.x-cart.w/2)*G_SCR_W) and (coo[0]<(cart.x+cart.w/2)*G_SCR_W) and (coo[1]<(cart.y+cart.h/2)*G_SCR_W) and (coo[1]>(cart.y-cart.h/2)*G_SCR_W) then
                exit(cart);
    for cart in cartes_deck do
        if (coo[0]>(cart.x-cart.w/2)*G_SCR_W) and (coo[0]<(cart.x+cart.w/2)*G_SCR_W) and (coo[1]<(cart.y+cart.h/2)*G_SCR_W) and (coo[1]>(cart.y-cart.h/2)*G_SCR_W) then
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
            cartes_deck[i].x := x/G_SCR_W;
            cartes_deck[i].y := y/G_SCR_W;
            cartes_deck[i].w := 0.036;
            cartes_deck[i].h := 0.056;
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
    if length(cartes)=0 then exit;
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
        cartes_main[i].x := x/G_SCR_W;
        cartes_main[i].y := y/G_SCR_W;
        cartes_main[i].w := w/G_SCR_W;
        cartes_main[i].h := h/G_SCR_W;
        x += (G_SCR_W*0.1+interval);
        end;
end;



procedure _convert_player(var pl:joueur); (* couleur et police *)
begin
    if length(pl.pseudo)=0 then exit;
    pl.pseudo_txt := gTextLoad(pl.pseudo,font_noms);
    pl.gcouleur := convert_couleur(pl.couleur);
end;

procedure load_players(var players_list:joueursArray);
var i, players_nbr, x, y:integer;
    theta:real;
begin
    players_nbr := length(players_list);
    x := G_SCR_W div 2;
    y := G_SCR_H div 2;
    SetLength(liste_joueurs,players_nbr);
    for i:=0 to players_nbr-1 do begin (* Initialisation des positions et des couleurs *)
        theta := 2*pi/players_nbr*i;
        players_list[i].x := round(cos(theta)*G_SCR_W*0.44) + x;
        players_list[i].y := round(sin(theta)*G_SCR_W*0.44) + y;
        _convert_player(players_list[i]);
        liste_joueurs[i] := players_list[i];
    end;
end;


procedure init(taille:integer);
var i:integer;
begin
    gLib2D.change_size(taille,taille);
    background := gTexLoad('tex.jpg'); (* Chargement de la texture *)
    font_cartes := TTF_OpenFont('font_cards.ttf', round(12.5));
    font_noms := TTF_OpenFont('font_names.ttf', round(17));
    font_msg := TTF_OpenFont('font_names.ttf', round(50));
    font_atout := TTF_OpenFont('font_cards.ttf', round(45));
    font_manche := TTF_OpenFont('font_cards.ttf', round(25));
    font_score := TTF_OpenFont('font_names.ttf', round(40));

    for i:=0 to high(cartes_deck) do (* rechargement des cartes *)
        convert_carte(cartes_deck[i]);
    set_deck(cartes_deck);
    for i:=0 to high(cartes_main) do
        convert_carte(cartes_main[i]);
    set_cartes_main(cartes_main);
    load_players(liste_joueurs); (* rechargement des joueurs *)
    _convert_player(joueur_actif); (* rechargement du joueur actif *)
end;

 begin
 TTF_Init()

end.
