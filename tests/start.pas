program gui;

uses gLib2D, graph, classes, sysutils, Crt;


var joueurs_list:classes.joueurs;
    une_carte:classes.carte;
    liste_cartes:array of classes.carte_graph;
    image:classes.background;
    players_graph : joueurs_graph;
    i: integer;
begin
    image := init(850); (* initialisation de la fenêtre *)
    SetLength(joueurs_list,5); (* Création de la liste des joueurs *)
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
    SetLength(liste_cartes,35); (* Création de cartes de test *)
    for i:=0 to high(liste_cartes) do begin
        une_carte.couleur := 'carreau';
        une_carte.valeur := 3;
        liste_cartes[i] := convert(une_carte);
        end;



    players_graph := load_players(joueurs_list); (* initialisation des joueurs *)
    while true do begin (* Boucle principale *)
        afficher_background(image); (* chargement du fond *)
        afficher_joueurs(players_graph); (* chargement des joueurs *)
        afficher_cartes(liste_cartes); (* chargement des cartes *)

        gFlip();

        while (sdl_update = 1) do (* si la fenêtre se met à jour (mouvement de la souris) *)
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;

        sleep(50);
    end;
end.
