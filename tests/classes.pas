Unit classes;

// ---------- PUBLIC ----------- //

interface

uses gLib2D;

Type config = Record // configuration de la partie
    players:integer;
    win_defaut:integer;
    win:integer;
    loose:integer;
    min_age:integer;
    max_age:integer;
    default_window_size:integer;
    end;

Type carte = Record // L'une des 52 cartes du jeu
    couleur:string;
    valeur:integer;
end;

Type joueur=Record // L'un des joueurs
    cartes:array of carte;
    pseudo:string;
    age:integer;
    couleur:byte;
    end;
Type joueurs=array of joueur;


Type deck = array[0..51] of carte; // Liste de toutes les cartes du jeu, triées

type joueur_graph=Record // uniquement les infos utiles
    pseudo:string;
    couleur:gColor;
    x,y:integer;
    pseudo_txt:gImage;
end;
Type joueurs_graph=array of joueur_graph;

type carte_graph=Record
    couleur:gColor;
    texte_petit:gImage;
    texte_grand:gImage;
end;

type text_graph=gImage; // texte lisible par la lib graphique
type color_graph=gColor;
type background=gImage;



// ---------- PRIVE ------------ //

implementation


end.
