Unit graph;

{$mode objfpc}


// ---------- PUBLIC ----------- //

interface

uses gLib2D, SDL, SDL_Image, SDL_TTF, Crt, sysutils, math, classes;

(* Initialisation *)
function init(taille:integer):gImage; // initialiser la fenêtre, et créer la référence de l'image de fond (/!\ à appeler en premier)

(* Convertir les données *)
function convert_carte(cart:carte):carte_graph; // Convertir une carte basique en une carte compatible avec la lib graphique
function load_players(players_list:joueurs):joueurs_graph; // Convertir la liste des joueurs de base en une liste utilisable par la lib graphique
function convert_text(message:string): text_graph; // Convertir un texte
function convert_couleur(couleur:byte):color_graph;

(* A appeler dans la boucle while *)
procedure afficher_cartes(liste:array of carte_graph;echelle:real=1.0); // afficher une liste de cartes, avec possibilité de réduire/augmenter la taille
procedure afficher_joueurs(players_graph:joueurs_graph); // Afficher la liste des joueurs autours de la "table"
procedure afficher_background(image:gImage); // Affiche l'image de fond
procedure afficher_texte(message:text_graph;couleur:color_graph); // Afficher un message
procedure refresh; // Afficher l'image

(* Partie SDL *)
function sdl_update : integer; // Retourne 1 lorsque quelque chose bouge sur l'écran (clic etc)
function sdl_do_quit : boolean; // Si l'utilisateur ferme la fenêtre
function sdl_get_mouse_x : Uint16; // Coordonnées x de la souris
function sdl_get_mouse_y : Uint16;
function sdl_mouse_left_up : boolean; // Si le joueur presse le bouton gauche de la souris
function sdl_mouse_left_down : boolean; // Si le joueur relâche le bouton gauche
function sdl_mouse_right_up : boolean;
function sdl_mouse_right_down : boolean;
function sdl_get_keypressed : integer; // Si une touche du clavier est pressée, retourne sa valeur (http://www.siteduzero.com/uploads/fr/ftp/mateo21/sdlkeysym.html)


// ---------- PRIVE ------------ //

implementation

var font_noms, font_cartes, font_msg:PTTF_Font; // polices des textes
    _event : TSDL_Event;

procedure refresh;
begin
    gFlip
end;

function sdl_update : integer;
begin
    exit(SDL_PollEvent(@_event));
end;

function sdl_do_quit : boolean;
begin
    exit(_event.type_ = SDL_QUITEV);
end;


function sdl_get_mouse_x : Uint16;
begin
    exit(_event.motion.x);
end;

function sdl_get_mouse_y : Uint16;
begin
    exit(_event.motion.y);
end;

function sdl_mouse_left_up : boolean;
begin
    exit((_event.type_ = SDL_MOUSEBUTTONUP)
    and  (_event.button.button = SDL_BUTTON_LEFT));
end;

function sdl_mouse_left_down : boolean;
begin
    exit((_event.type_ = SDL_MOUSEBUTTONDOWN)
    and  (_event.button.button = SDL_BUTTON_LEFT));
end;

function sdl_mouse_right_up : boolean;
begin
    exit((_event.type_ = SDL_MOUSEBUTTONUP)
    and  (_event.button.button = SDL_BUTTON_RIGHT));
end;

function sdl_mouse_right_down : boolean;
begin
    exit((_event.type_ = SDL_MOUSEBUTTONDOWN)
    and  (_event.button.button = SDL_BUTTON_RIGHT));
end;


function sdl_get_keypressed : integer;
begin
    if (_event.type_ <> SDL_KEYDOWN) then
        exit(-1);

    exit(_event.key.keysym.sym);
end;




function convert_carte(cart:carte):carte_graph;
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
    convert_carte.texte := gTextLoad(couleur+inttostr(cart.valeur),font_cartes);
    if (couleur='[') or (couleur='{') then
        convert_carte.couleur := gLib2D.RED
    else
        convert_carte.couleur := gLib2D.BLACK;
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

procedure afficher_carte(x,y:real;cart:carte_graph;font_cartes:PTTF_Font;echelle:real=1);
var w,h:real;
begin
    w := G_SCR_W*0.033*echelle;
    h := G_SCR_H*0.056*echelle;
    gFillRect(x-w/2,y-h/2,w,h,gLib2D.WHITE);
    gDrawRect(x-w/2,y-h/2,w,h,gLib2D.BLACK);
    gBeginRects(cart.texte);
        gSetCoordMode(G_CENTER);
        gSetColor(cart.couleur);
        gSetCoord(x,y-10*echelle);
        gAdd();
    gEnd();
end;

procedure afficher_cartes(liste:array of carte_graph;echelle:real=1.0);
var i,j,k,interval:integer;
    x,y:real;
begin
    interval := 5;
    x := (G_SCR_H div 2)-min(19,length(liste)-2)*(G_SCR_W*0.033+interval)*echelle/2;
    y := G_SCR_H*0.65;
    j := 0; i := 0;
    while i<length(liste) do begin
        k := i;
        while j<min(20,length(liste)-k) do begin
            //writeln('    j=',j,' i=',i);
            afficher_carte(x,y,liste[i],font_cartes,echelle);
            x += (G_SCR_W*0.033+interval)*echelle;
            j += 1;
            i += 1;
        end;
        //writeln(min(20,length(liste)-k-1),' j=',j,' i=',i);
        j := 0;
        y += (G_SCR_H*0.056-5)*echelle;
        x := (G_SCR_H div 2)-min(19,length(liste)-i-1)*((G_SCR_W*0.033+interval)*echelle)/2;
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


function init(taille:integer):gImage;
begin
    gLib2D.change_size(taille,taille);
    gClear(gLib2D.BLACK);
    init := gTexLoad('tex.jpg'); (* Chargement de la texture *)
    font_cartes := TTF_OpenFont('font_cards.ttf', round(G_SCR_W*0.015));
    font_noms := TTF_OpenFont('font_names.ttf', round(G_SCR_W*0.02));
    font_msg := TTF_OpenFont('font_names.ttf', round(G_SCR_W*0.06));
end;

function load_players(players_list:joueurs):joueurs_graph;
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
        load_players[i].couleur := convert_couleur(players_list[i].couleur);
    end;
end;

procedure afficher_background(image:gImage);
var x,y,w,h:integer;
begin
    x := G_SCR_W div 2; (* Milieu de l'écran *)
    y := G_SCR_H div 2; (* Milieu de l'écran *)
    w := G_SCR_W; (* Largeur de l'écran *)
    h := G_SCR_H; (* Hauteur de l'écran *)
    gBeginRects(image); (* Ajout de l'image de fond *)
        gSetCoordMode(G_CENTER);
        gSetScaleWH(w, h);
        gSetCoord(x, y);
        gAdd();
    gEnd();
end;

 begin
 TTF_Init()

end.
