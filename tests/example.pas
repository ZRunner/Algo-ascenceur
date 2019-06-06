program gui;

uses gLib2D, graph, classes, sysutils, Crt;


var joueurs_list:classes.joueursArray;
    une_carte,atout:classes.carte;
    liste_cartes:CartesArray;
    liste_manche:array[0..4] of classes.carte;
    image:classes.background;
    i,t: integer;
    text:text_graph;
begin
    randomize;
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
    text := convert_text('Welcome!');
    SetLength(liste_cartes,33); (* Création de cartes de test *)
    for i:=0 to high(liste_cartes) do begin
        une_carte.couleur := 'carreau';
        une_carte.valeur := round(random*10)+1;
        liste_cartes[i] := une_carte;
        convert_carte(liste_cartes[i]);
        if i<3 then liste_manche[i] := liste_cartes[i];
        if i=high(liste_cartes) then atout := une_carte;
        end;
    joueurs_list := load_players(joueurs_list); (* initialisation des joueurs *)
    set_deck(liste_cartes);
    set_cartes_main(liste_manche);
    set_joueur(joueurs_list[round(random*4)]);

    t := 0;

    while true do begin (* Boucle principale *)
        afficher_background(image); (* chargement du fond *)
        afficher_atout(atout);
        afficher_joueurs(joueurs_list); (* chargement des joueurs *)
        afficher_cartes; (* chargement des cartes *)
        afficher_texte(text,convert_couleur(blue));
        focus_joueur;
        afficher_manche;
        afficher_cadre();

        gFlip();


        while (sdl_update = 1) do begin (* si la fenêtre se met à jour (mouvement de la souris) *)
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;
                une_carte := on_click;
                if une_carte.valeur<>-1 then writeln('carte cliquée: ',une_carte.valeur);
            end;

        sleep(10);

        t += 1;
         if t>50 then begin
            set_joueur(joueurs_list[round(random*4)]);
            t := 0;
            end;

    end;
end.
