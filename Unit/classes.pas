Unit classes;

// ---------- PUBLIC ----------- //

interface

uses gLib2D;

Type config = Record // configuration de la partie
    players : integer;
    win_defaut : integer;
    win : integer;
    loose : integer;
    min_age : integer;
    max_age : integer;
    default_window_size : integer;
end;

Type carte = Record // L'une des 52 cartes du jeu
    couleur : string;
    valeur : integer;
    gcouleur : gColor;
    texte_petit : gImage;
    texte_grand : gImage;
    x,y,w,h : real;
end;
Type cartesArray = array of carte;

Type joueur = Record // L'un des joueurs
    cartes : array of carte;
    pseudo : string;
    age : integer;
    couleur : byte;
    pari : integer;
    point : integer;
    PliManche : integer; //nombre de pli remporté par manche
    gcouleur : gColor;
    x,y,r : integer;
    pseudo_txt : gImage;
    bot:boolean; //comme la liste change, il faut pouvoir repérer les bots dans la liste
end;

Type deck = array[0..51] of carte; // Liste de toutes les cartes du jeu, triées
Type joueurs = array of joueur; // Liste de tous les joueurs du jeu dans l'unit deroulement
Type joueursArray = array of joueur; //dans l'unit graph

type text_graph = gImage; // texte lisible par la lib graphique
type color_graph = gColor;
type background = gImage;



// ---------- PRIVE ------------ //

implementation


end.
