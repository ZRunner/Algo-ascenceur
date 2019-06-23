program ProjetAscenseur;

uses loadconfig, Intro, bot, graph, classes,  deroulement, Crt, sysutils;

var 
	n:integer; //nombre de joueurs non bots
	x:integer; //nombre de cartes par joueur au début d'une manche (par distribution)
	i:integer; //implementation du numéro du joueur dans la liste
	p:integer; //numéro du pli en fonction de la manche
	m:integer; //numéro de la manche (voir si on fait 2 variables en fonction de la phase)
	Ph:integer; //numéro de la phase, 1 pour Ascendante et 2 pour Descendante
	C:array of carte; //ensemble des cartes du pli
	choix:carte; //carte choisie par un joueur
	boo:boolean; //pari fait en début de manche ou non 
	s,max:integer; //pour l’initialisation des comptes de paris
	j:integer; //pour les boucle for 
	atout:carte;
	besoin_carte:boolean; // besoion de demander une carte
begin
    randomize;

    (* initialisation des principales variables du programme *)
    x:=1;
    i:=0; 
    boo:=false; 
    p:=1; 
    m:=1;
    Ph:=1;

    conf:=loadconf('config.txt'); // Charge la config de la partie
    Demande; // Demande au joueur s’il veut les règles et si oui, les affiche 
    n:=InitJoueur(); // Demande le nombre de joueurs dans la partie hors bots
	setlength(liste, conf.players); 
	creerjoueurs(liste); // Donne un pseudo, un âge à chaque joueurs de la partie
	plusJeune(liste);
	If (n<conf.players) Then
		PartieBot(n,liste); // Donne un pseudo et un âge aux bots
	load_players(liste); // Ajoute les données liées au graphique 
	

	For j:=0 to high(liste[i].cartes) do
		convert_carte(liste[i].cartes[j]);

	set_deck(liste[i].cartes); // initialise un paquet de carte comme celui du premier joueur (emplacement du deck)  
	set_joueur(liste[i]); // initialise le premier joueur dans le focus
	set_fps(50); // 50 images par secondes max (évite les lags)
	 setlength(C,high(liste)+1); 

	(* Boucle Principale *)
	while true do
	begin
		afficher_background; // Affiche le fond d’écran
		afficher_joueurs; // Affiche les joueurs et les bots sur l’écran
		afficher_cartes; // Chargement des cartes
		afficher_manche; //Chargement des cartes au centre (rien quand c les tour de paris)
		focus_joueur;
		afficher_cadre(); // Affichage d'un cadre au survol d'une carte
		refresh(); //mise à jour avec les éléments chargés
		

		while (sdl_update = 1) do begin (* si la fenêtre se met à jour (mouvement de la souris) *)
        If (sdl_do_quit) then (* Clic sur la croix pour fermer *)
                exit;
        If besoin_carte Then
    choix := on_click;
		end;
		
		If (p=1) and (i=0) Then atout:=InitAtout(liste,x); // Distribution des cartes aux joueurs et initialisation de l’atout


If  boo=true Then
begin
		besoin_carte := True;
		If choix.valeur = -1 then continue;
			RetirePaquet(liste[i],choix);
			convert_carte(choix);
			C[i]:=choix;
			i += 1;
		end
		Else
begin
	If (i=0) Then
begin
s:=0;
		max:=high(liste)+1;
			end;
Parions(liste[i],x,s,max);
Inc(i);
			if (i=high(liste)+1) Then
			begin
 boo:=true; //paris faits pour tous les joueurs
i:=0;
end;
		end;

If i>high(liste) Then 
		begin
			OrdreJoueur(liste,atout,C); //met la liste dans l'ordre de jeu pour le prochain pli (gagnant en premier)
			i:=0; //retour au premier joueur
			Inc(liste[i].PliManche);
			Inc(p); 
		end; //un pli est fini -> pli suivant
		
		If (p>x) and (Ph=1) Then
		begin
			Inc(x); //une carte de plus par joueur à la prochaine distribution
			p:=1; //retour au pli numéro 1 mais de la manche suivante
			Inc(m);
			ComptageDePoint(liste);
			afficher_score(liste,7);
			boo:=false;
		end; //une manche est finie pendant la phase 1
		
		If (p>x) and (Ph=2) Then
		begin
			Inc(x,-1); //une carte de moins par joueur à la prochaine distribution
			p:=1; //retour au pli numéro 1 mais de la manche suivante
			Inc(m); 
			ComptageDePoint(liste);
			afficher_score(liste,7); //le tableau des scores s'affiche 7 secondes
			boo:=false;
		end; //une manche est finie pendant la phase 2
		
		If (m>NombreManche) and (Ph=1) Then
		begin
			m:=1; //réinitialise le numéro de la manche
			Inc(x,-1); //car on démarre la prochaine manche avec le même x que la manche d'avant (qui a été incrémenter pour montrer le changement de pli puis de manche)
			Inc(Ph);
		end; //la phase ascendante est finie -> passage phase descendante
		
		(*nouveaux paramètres pour l'affichage*)

	For j:=0 to high(liste[i].cartes) do
			convert_carte(liste[i].cartes[j]); //pour que les cartes soit compatible avec le graphisme

		set_deck(liste[i].cartes); //Chargement des cartes du joueur suivant
		set_joueur(liste[i]); //Chargement du joueur suivant en focus
		set_cartes_main(C); //Chargement des cartes du pli au centre
	end;
end.
