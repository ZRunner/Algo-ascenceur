program gui;

uses graph, classes, sysutils, Crt;


var joueurs_list:classes.joueursArray;
    une_carte,atout:classes.carte;
    liste_cartes:CartesArray;
    liste_manche:array[0..4] of classes.carte;
    i,t: integer;
    text:text_graph;
    input:string;
begin
    randomize;
    init(850); (* initialisation de la fenêtre *)
    SetLength(joueurs_list,5); (* Création de la liste des joueurs *)
    joueurs_list[0].pseudo := 'Z_runner';
    joueurs_list[0].couleur := red;
    joueurs_list[0].point := round(random(30));
    joueurs_list[1].pseudo := 'MelyMelo8';
    joueurs_list[1].couleur := YELLOW;
    joueurs_list[1].point := round(random(30));
    joueurs_list[2].pseudo := 'Moustique';
    joueurs_list[2].couleur := blue;
    joueurs_list[2].point := round(random(30));
    joueurs_list[3].pseudo := 'Awhikax';
    joueurs_list[3].couleur := green;
    joueurs_list[3].point := round(random(30));
    joueurs_list[4].pseudo := 'loann';
    joueurs_list[4].couleur := magenta;
    joueurs_list[4].point := round(random(30));
    text := convert_text('Welcome!');
    SetLength(liste_cartes,33); (* Création de cartes de test *)
    for i:=0 to high(liste_cartes) do begin
        if random>0.5 then
            une_carte.couleur := 'carreau'
        else
            une_carte.couleur := 'pique';
        une_carte.valeur := round(random*13)+1;
        liste_cartes[i] := une_carte;
        convert_carte(liste_cartes[i]);
        if i<3 then liste_manche[i] := liste_cartes[i];
        if i=high(liste_cartes) then atout := une_carte;
        end;
    load_players(joueurs_list); (* initialisation des joueurs *)
    set_deck(liste_cartes); (* initialisation des cartes de deck *)
    set_cartes_main(liste_manche); (* initialisation des cartes au milieu de la table *)
    set_joueur(joueurs_list[round(random*4)]); (* ajout d'un joueur random en focus *)
    set_fps(40); (* 50 images par seconde max (évite les lags) *)

    t := 0;


    while true do begin (* Boucle principale *)
        afficher_background; (* chargement du fond *)
        afficher_atout(atout); (* chargement de la couleur de l'atout *)
        afficher_joueurs; (* chargement/affichage des joueurs *)
        afficher_cartes; (* chargement des cartes *)
        afficher_texte(text,convert_couleur(blue)); (* affichage d'un texte *)
        focus_joueur; (* affichage du joueur en focus *)
        afficher_manche; (* affichage des cartes jouées *)
        afficher_cadre(); (* affichage d'un cadre au survol d'une carte *)

        refresh(); (* mise à jour de l'image avec les données précédemment chargées *)

        if t>99 then begin
            input := saisir_txt('Entrez la nouvelle largeur d''ecran',3,true); (* texte à afficher, longueur max, chiffre seulement *)
            init(StrToInt(input)); (* changement de la taille d'écran *)
            load_players(joueurs_list); (* rechargement de la police à cause du changement de taille*)
            text := convert_text('Welcome!'); (* idem *)

            //afficher_score(joueurs_list,7);
            end;
        

        while (sdl_update = 1) do begin (* si la fenêtre se met à jour (mouvement de la souris) *)
            if (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;
            une_carte := on_click;

            if une_carte.valeur<>-1 then
                writeln('carte cliquée: ',une_carte.valeur);
            end;


        t += 1;
         if t>100 then begin (* juste pour faire une boucle paske c koul *)
            t := 0;
            end;

    end;
end.
