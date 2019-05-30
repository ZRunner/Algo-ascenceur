Unit classes;

// ---------- PUBLIC ----------- //

interface

uses gLib2D;

Type joueur=Record // L'un des joueurs
    pseudo:string;
    couleur:byte;
end;
Type joueurs=array of joueur;

Type carte = Record // L'une des 52 cartes du jeu
    couleur:string;
    valeur:integer;
end;

type joueur_graph=Record // uniquement les infos utiles
    pseudo:string;
    couleur:gColor;
    x,y:integer;
    pseudo_txt:gImage;
end;
Type joueurs_graph=array of joueur_graph;

type carte_graph=Record
    couleur:gColor;
    texte:gImage;
end;

type background=gImage;



// ---------- PRIVE ------------ //

implementation


end.
