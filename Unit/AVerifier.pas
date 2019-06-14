UNIT Bot;

interface

USES Intro, graph, classes, Crt, sysutils, deroulement;

implementation

CONST pseudos : array[0..3] of string = ('Panda','Couscous','Manhattan','Cyan','Axolotl');

Function CreerBot():joueur;
begin
	randomize;
	creerBot.pseudo := pseudos[round(random(5))];
	creerBot.age:=random(80)+8;
end;

Procedure PartieBot();
var n:integer;
	p:joueur;
begin
	n:=InitJoueur();
	Writeln('Combien voulez-vous de Bot?');
	Readln(n)
	For i:=1 to n do
		p:=CreerBot();
	Partie();
end;

Procedure ParionsBot(var liste:joueursArray;n:integer);
var i,k,s,m:integer;
begin
	s:=0;
	m:=n+1;
	For i:=0 to high(liste) do
	begin
			graph.set_joueur(liste[i]);
			k:=-1;
		While (k<0) or (k>m) do
		begin
			k := StrToInt(saisir_txt('Combien de plis pensez-vous remportez ?',2,true));
			(* 2 : pari = nombre de 2 chiffres max
			* true : le joueur ne peut rentrer que des chiffres *)
		end;
	liste[i].pari:=random(m+2);
	s:=s+k;
	m:=m-s;
    end;
end;

Function ChoixCarte(paquet:joueur):carte;
begin
	Repeat
		Repeat
			writeln('Couleur de la carte que vous voulez jouer :');
			ChoixCarte.couleur:=random(carte.couleur);
		Until VerifCouleurExiste(ChoixCarte.couleur); //vérifier couleur choisie existe
		Repeat
			writeln('Valeur de cette dernière');
			ChoixCarte.couleur:=random(carte.valeur);
		Until VerifValeurExiste(p); //vérifier que la carte est bien entre 1 et roi (13)
	Until VerifieCarteAjoueur(paquet,ChoixCarte); //vérifie que la carte peut être jouer par le joueur
end;

Function VerifDroitDePoser(paquet:joueur;choix,prems:carte):boolean;
var i:integer;
begin
	If (choix.couleur=prems.couleur) Then
		VerifDroitDePoser:=true
	Else
	begin
		VerifDroitDePoser:=true; //initialisation
		For i:=0 to high(paquet.cartes) do
		begin
			If (paquet.cartes[i].couleur=prems.couleur) Then Exit(false);
			end;
		end;
end;

Function ChoixCarteCouleurBot(packet:joueur;prems:carte):carte;
var i,j:integer;
	T:array of carte;
begin
	randomize;
	Setlength(T,high(packet.cartes));
    j := 0;
	For i:=0 to high(packet.cartes) do
        If carte.couleur:=prems.couleur then begin
			T[j]:=carte;
            j += 1;
            end;
    Setlength(T,j);
	ChoixCarteCouleurBot:=T[round(random(length(T)))];
end;

Procedure RetirePaquet(var Jo:joueur;choix:carte);
var i,j:integer; G:array of carte;
begin
	setlength(G,length(Jo.cartes)-1);
	j:=0;
	For i:=0 to high(G) do
	begin
		If (Jo.cartes[j].couleur<>choix.couleur) or (Jo.cartes[j].valeur<>choix.valeur) then G[i]:=Jo.cartes[j];
		j:=j+1;
	end;
end;

//pour un tour, renvoit un entier qui est le numéro du gagnant dans la liste actuelle
Function Pli(var liste:joueursArray; atout:string):integer;
var
	i:integer;
	T:array of carte;
	choix:carte;
	best:integer;
begin
	set_deck(liste[0].cartes);
	afficher_cartes;
	set_joueur(liste[0]);
    focus_joueur; //affichage en haut à gauche du joueur dont c'est le tour
	setlength(T,high(liste));
	T[0].couleur:=ChoixCarte(liste[0]).couleur;
	T[0].valeur:=ChoixCarte(liste[0]).valeur;
	RetirePaquet(liste[0],choix);
	set_cartes_main(T);
	afficher_manche; //affichage des cartes jouées au centre
	best:=0;
	set_deck(liste[1].cartes);
	afficher_cartes;
	set_joueur(liste[1]);
    focus_joueur;
	For i:=1 to high(liste) do
	begin
		Repeat
			choix.couleur:=ChoixCarte(liste[i]).couleur; //choix est dans le paquet du joueur
			choix.valeur:=ChoixCarte(liste[i]).valeur;
		Until VerifDroitDePoser(liste[i],choix,T[0]);
		RetirePaquet(liste[i],choix);
		T[i]:=choix;
		set_cartes_main(T);
		afficher_manche;
		if i<>high(liste) then
		begin
			set_deck(liste[i+1].cartes);
			afficher_cartes;
			set_joueur(liste[i+1]);
			focus_joueur; //affichage en haut à gauche du joueur dont c'est le tour
		end;
		If (T[i].couleur=T[0].couleur) then
		begin
			If (T[i].couleur=T[best].couleur) then
				If (T[i].valeur>T[best].valeur) then best:=i; //si atout pas encore posé
		end
		Else
		begin
			If (T[i].couleur=T[best].couleur) then  //si atout déjà posé
				If (T[i].valeur>T[best].valeur) then best:=i
		end;
	end;
	Exit(best); //voir pour un effet sur T[best]
end;

//Function retrouvant dans la liste le pseudo du gagnant.
Function RecherchePseudoGagnant(liste:joueursArray;atout:string):joueur;
var i: integer;
begin
	For i:=1 to high(liste) do
		If Pli(liste,atout)= i then
			Exit(liste[i]);
end;

// Procédure permettant d'afficher l'ordre des joueurs pour le pli suivant.
Procedure OrdreJoueur(var liste:joueursArray;atout:string);
var i,j,x:integer;
T:joueursArray;
begin
	setlength(T,high(liste)+1);
	T[0]:=RecherchePseudoGagnant(liste,atout);
	For i:=1 to high(liste) do
		If T[0].pseudo=liste[i].pseudo Then x:=i;
	j:=x+1;
	For i:=1 to high(T) do
	begin
		T[i]:=liste[j];
		j:=j+1;
		if j=high(liste) then j:=0
	end;
end;

//pour afficher les scores en chaque fin de manche
Procedure AfficheScore(liste:joueursArray);
Var i:integer;
begin
	graph.afficher_score(liste,20); // 20 : nombre de secondes d'affichage
end;

// n est le nombre de carte distribuer par joueur
Procedure ComptageDePoint(var liste:joueursArray;n:integer);
var i:integer; conf:config;
begin
	conf.win_defaut:=10;
	conf.win:=2;
	for i:=0 to high(liste) do
	begin
    	If  liste[i].pari = liste[i].PliManche then
        	liste[i].point := liste[i].point + 10 + conf.win*liste[i].pari
    	Else
        	liste[i].point := liste[i].point + 10-Abs(liste[i].pari-liste[i].PliManche)*conf.win;
	end;
	InitPliManche(liste);
end;

//pour une manche
Procedure Manche(var liste:joueursArray;n:integer); //n : nombre de cartes par joueur au début de la manche
var i:integer; atout:carte; color:string;
begin
	atout:=InitAtout(liste,n);
	afficher_atout(atout); (* chargement de la couleur de l'atout *)
	color:=atout.couleur;
	Parions(liste,n);
	For i:=1 to n do //premier joueur = gagnant tour précédent
	begin
		OrdreJoueur(liste,color);
		liste[0].PliManche:=liste[0].PliManche+1;
	end;
	ComptageDePoint(liste,n);
	AfficheScore(liste);
end;

//la phase ascendante
Procedure Ascendant(liste:joueursArray;conf:config);
var i,x:integer;
begin
	x:=NombreManche(conf);
	For i:=1 to x do
	begin
		distribuer(liste,i);
		Manche(liste,i);
	end;

end;

//la phase descendante
Procedure Descendant(liste:joueursArray;conf:config);
var i,x:integer;
begin
	x:=NombreManche(conf);
	For i:=x downto 1 do
	begin
		distribuer(liste,i);
		Manche(liste,i);
	end;
end;


END.
