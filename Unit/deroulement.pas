UNIT deroulement;

interface
uses loadconfig, Intro, bot, graph, classes, Crt, sysutils;

var d:deck;
    liste:joueursArray;
    conf:config;

Function InitJoueur():integer;
Procedure InitPliManche(var liste:joueursArray);
function inarray(liste:array of carte;card:carte):boolean;
function init:deck;
procedure distribuer(var liste:joueursArray;n:integer);
Procedure Parions(var liste:joueursArray;n:integer);
Procedure plusJeune(var liste:joueursArray);
Function RandomDeck:deck;
Function InitAtout(liste:joueursArray;n:integer):carte;
Function NombreManche():integer;
Function VerifCouleurExiste(colo:string):boolean;
Function VerifValeurExiste(val:integer):boolean;
Function VerifieCarteAjoueur(paquet:joueur;Choix:carte):boolean;
Function ChoixCarte(paquet:joueur):carte;
Function VerifDroitDePoser(paquet:joueur;choix,prems:carte):boolean;
Function Pli(var liste:joueursArray;atout:string):integer;
Procedure RetirePaquet(var Jo:joueur;choix:carte);
Procedure OrdreJoueur(var liste:joueursArray;atout:string);
Procedure AfficheScore(liste:joueursArray);
Procedure Manche(var liste:joueursArray;n:integer);
Procedure Ascendant(liste:joueursArray);
Procedure Descendant(liste:joueursArray);
Procedure ComptageDePoint(var liste:joueursArray;n:integer);
function creerjoueur(couleur:byte;colorname:string):joueur;
procedure creerjoueurs(var liste:joueursArray);
Procedure Partie(var liste:joueursArray);

implementation

//initialise le nombre de joueurs
Function InitJoueur():integer;
var n:integer;
begin
	writeln('Combien de joueurs êtes-vous?');
	readln(n);
	Exit(n);
end;

//remise à zéro du nombre de pli réalisé par joueur par manche
Procedure InitPliManche(var liste:joueursArray);
var i:integer;
begin
	For i:=0 to high(liste) do
		liste[i].PliManche:=0;
end;


// Vérifie si une carte se trouve dans une liste de cartes
function inarray(liste:array of carte;card:carte):boolean;
var i:integer;
begin
    for i:=0 to high(liste) do
        if (liste[i].couleur = card.couleur) and (liste[i].valeur = card.valeur) then Exit(True);
    Exit(False);
end;

// Initialise le jeu, en créant le paquet de 52 cartes
function init:deck;
var i,j:integer;
    couleur:string;
    cs:array[0..3] of string=('carreau','pique','trefle','coeur');
begin
    j := 0;
    for couleur in cs do
        for i:=2 to 14 do begin
            init[j].couleur := couleur;
            init[j].valeur := i;
            j := j+1;
            end;
end;

//distribue les cartes par joueurs
procedure distribuer(var liste:joueursArray;n:integer);
var i,k,p:integer;
    utilises:deck;
begin
    k := 0;
    for p:=0 to high(liste) do begin
        setlength(liste[p].cartes,n);
        for i:=0 to n-1 do begin
            liste[p].cartes[i] := d[random(52)];
            while inarray(utilises,liste[p].cartes[i]) do
                liste[p].cartes[i] := d[random(52)];
            utilises[k] := liste[p].cartes[i];
            k := k+1;
            end;
        end;
end;

//enregistrement des paris
Procedure Parions(var liste:joueursArray;n:integer); //n:nb de cartes par joueur
var i,k,s,m:integer;
begin
	s:=0;
	m:=n+1;
	For i:=0 to high(liste) do
	begin
        graph.set_joueur(liste[i]);
		k:=-1;
		If (liste[i].bot=false) then
		begin
			While (k<0) or (k>m) do
			begin
				k := StrToInt(saisir_txt('Combien de plis pensez-vous remportez ?',2,true));
				(* 2 : pari = nombre de 2 chiffres max
				* true : le joueur ne peut rentrer que des chiffres *)
			end;
		end
		Else
			k:=random(m);
		liste[i].pari:=k;
		s:=s+k;
		m:=m-s;
	end;
end;

//changer la liste avec le premier joueur premier liste au début de la partie
Procedure plusJeune(var liste:joueursArray);
var i,j,x:integer; T:joueursArray;
begin
	setlength(T,high(liste)+1);
	T[0]:=liste[0];
	For i:=1 to high(liste) do
	begin
		if liste[i].age < liste[i-1].age then
		begin
			T[0]:=liste[i];
			x:=i;
		end;
	end;
	j:=x+1;
	For i:=1 to high(T) do
	begin
		T[i]:=liste[j];
		j:=j+1;
		if j=high(liste) then j:=0
	end;
end;

Function RandomDeck:deck;
var p:deck; i,k:integer; utilises:deck;
Begin
 k := 0;
        for i:=0 to 51 do begin
            p[i] := d[random(52)];
            while inarray(utilises,p[i]) do
                p[i] := d[random(52)];
            utilises[k] := p[i];
            k := k+1;
		end;
	Exit(p);
end;

// Pour vérifier que l'atout n'est pas dans un seul paquet des joueurs
Function VerifAtout(liste:joueursArray;card:carte):boolean;
var j,i:integer;
begin
    For i:=0 to high(liste) do
        For j:=0 to high(liste[i].cartes) do
            if ((liste[i].cartes[j].couleur = card.couleur) and (liste[i].cartes[j].valeur = card.valeur)) then exit(false);
    Exit(true);
end;

// n = nbr de cartes par joueur et p = nombre de players
Function InitAtout(liste:joueursArray;x:integer):carte;
var k:carte;
begin
Distribuer(liste,x);
Repeat
    k:=d[random(52)];
until VerifAtout(liste,k);
InitAtout:=k;
end;

// Calcule le nombre de manches dans une partie en fonction du nombre de joueurs.
Function NombreManche():integer;
begin
conf.players:=InitJoueur();
NombreManche:=round(52/conf.players);
If (conf.players=2) or (conf.players=4) then
NombreManche:=NombreManche-1;
end;

//Fonction pour vérifier si la couleur choisi par le joueur sur le terminal existe
Function VerifCouleurExiste(colo:string):boolean;
begin
	If (colo='trefle') Then VerifCouleurExiste:=true
	Else If (colo='pique') Then VerifCouleurExiste:=true
	Else If (colo='coeur') Then VerifCouleurExiste:=true
	Else If (colo='carreau') Then VerifCouleurExiste:=true
	Else VerifCouleurExiste:=false;
end;

//function vérifiant si la valeur de la carte existe
Function VerifValeurExiste(val:integer):boolean;
begin
	If (val>0) and (val<14) then VerifValeurExiste:=true
	Else VerifValeurExiste:=false;
end;

//Fonction vérifiant carte est dans le paquet du joueur choisi
Function VerifieCarteAjoueur(paquet:joueur;Choix:carte):boolean;
var i:integer;
begin
	VerifieCarteAjoueur:=false;
	For i:=0 to high(paquet.cartes) do
	begin
		if (Choix.couleur=paquet.cartes[i].couleur) and (Choix.valeur=paquet.cartes[i].valeur) Then VerifieCarteAjoueur:=true;
	end;
end;

//Fonction qui demande et renvoit le choix d'une carte par un joueur dans son paquet
Function ChoixCarte(paquet:joueur):carte;
begin
	Repeat
		Repeat
			writeln('Couleur de la carte que vous voulez jouer :');
			readln(ChoixCarte.couleur);
		Until VerifCouleurExiste(ChoixCarte.couleur); //vérifier couleur choisie existe
		Repeat
			writeln('Valeur de cette dernière');
			readln(ChoixCarte.valeur);
		Until VerifValeurExiste(ChoixCarte.valeur); //vérifier que la carte est bien entre 1 et roi (13)
	Until VerifieCarteAjoueur(paquet,ChoixCarte); //vérifie que la carte peut être jouer par le joueur
end;

//vérifie si la carte peut être jouer en fonction du jeu et de la première carte
Function VerifDroitDePoser(paquet:joueur;choix,prems:carte):boolean;
var i:integer;
begin
	If (choix.couleur=prems.couleur) Then VerifDroitDePoser:=true
	Else
	begin
		VerifDroitDePoser:=true; //initialisation
		For i:=0 to high(paquet.cartes) do
		begin
			If (paquet.cartes[i].couleur=prems.couleur) Then Exit(false);
		end;
	end;
end;

Procedure RetirePaquet(var Jo:joueur;choix:carte);
var	i,j:integer; G:array of carte;
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
	If liste[0].bot = true then
	begin
		T[0]:=ChoixCarteBotPrems(liste[0]);
	end
	Else
	begin
		T[0].couleur:=ChoixCarte(liste[0]).couleur;
		T[0].valeur:=ChoixCarte(liste[0]).valeur;
	end;
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
		If liste[i].bot = false then
		begin
			Repeat
				choix.couleur:=ChoixCarte(liste[i]).couleur; //choix est dans le paquet du joueur
				choix.valeur:=ChoixCarte(liste[i]).valeur;
			Until VerifDroitDePoser(liste[i],choix,T[0]);
		end
		Else
		begin
			choix:=ChoixCarteCouleurBot(liste[i],T[0]);
		end;
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
				If (T[i].valeur>T[best].valeur) then best:=i;
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
	For i:=0 to high(liste) do
	begin
		writeln(liste[i].pseudo, ' : ', liste[i].point);
	end;
end; //à retoucher avec Arthur pour l'adapter au graphisme

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
Procedure Ascendant(liste:joueursArray);
var i,x:integer;
begin
	x:=NombreManche();
	For i:=1 to x do
	begin
		distribuer(liste,i);
		Manche(liste,i);
	end;

end;

//la phase descendante
Procedure Descendant(liste:joueursArray);
var i,x:integer;
begin
	x:=NombreManche();
	For i:=x downto 1 do
	begin
		distribuer(liste,i);
		Manche(liste,i);
	end;
end;

// Création d'un joueur, avec son pseudo, sa couleur et son age
function creerjoueur(couleur:byte;colorname:string):joueur;
var age:integer;pseudo:string;ok:boolean;
begin
    textcolor(couleur);
    creerjoueur.couleur := couleur;
    write('Joueur ',colorname,', indiquez votre pseudo',#10,'> ');readln(pseudo);
    {$I-}   {compiler directive, removes abort on IO error}
    write('Indiquez votre âge',#10,'> ');readln(age);
    while (conf.min_age>age) or (age>conf.max_age) or (IOResult <> 0) do begin
        ok := IOResult=0;
        write('Indiquez votre âge',#10,'> ');readln(age);
    end;
    {$I+}   {restores default IO checking}
    creerjoueur.age := age;
    creerjoueur.pseudo := pseudo;
    creerjoueur.bot:=false;
    writeln;
end;

// Création de la liste de tous les joueurs
procedure creerjoueurs(var liste:joueursArray);
var i:integer;
    cls:array[0..6] of byte=(red,yellow,blue,green,Magenta,Brown,LightGray);
    clsn:array[0..6] of string=('Rouge','Jaune','Bleu','Vert','Violet','Marron','Blanc');
begin
    for i:=0 to high(liste) do
        liste[i] := creerjoueur(cls[i],clsn[i]);
    normvideo;
end;

//Procedure rassemblant tout pour jouer une partie
Procedure Partie(var liste:joueursArray);
Var
	n:integer;
begin
	n:=InitJoueur();
	setlength(liste, conf.players);
	creerjoueurs(liste);
	If (n<conf.players) Then
		PartieBot(n,liste);
	load_players(liste);
	afficher_joueurs(); (* chargement/affichage des joueurs *)
	plusJeune(liste);
	afficher_background(); (* chargement du fond *)
	Ascendant(liste);
	Descendant(liste);
end;

end.
