UNIT deroulement;

// x= Nombre de cartes par joueurs;
// n= Nombre de joueurs(Non bot);
// high(liste)= Nombre de joueurs au total (Joueurs et bots)

interface
uses loadconfig, bot, graph, classes, Crt, sysutils;

var d:deck;
    liste:joueursArray;
    conf:config;

Function InitJoueur():integer;
Procedure InitPliManche(var liste:joueursArray);
function inarray(liste:array of carte;card:carte):boolean;
function init:deck;
procedure distribuer(var liste:joueursArray;n:integer);
Procedure Parions(var liste:joueursArray;n:integer; var s,m:integer);
Procedure plusJeune(var liste:joueursArray);
Function RandomDeck:deck;
Function InitAtout(liste:joueursArray;x:integer):carte;
Function VerifAtout(liste:joueursArray;card:carte):boolean;
Function NombreManche():integer;
Function VerifCouleurExiste(colo:string):boolean;
Function VerifValeurExiste(val:integer):boolean;
Function VerifieCarteAjoueur(paquet:joueur;Choix:carte):boolean;
Function ChoixCarte(paquet:joueur):carte;
Function VerifDroitDePoser(paquet:joueur;choix,prems:carte):boolean;
Function BestPli(T:array of carte;atout:carte):integer;
Procedure RetirePaquet(var Jo:joueur;choix:carte);
Procedure OrdreJoueur(var liste:joueursArray;atout:carte;C:Array of carte);
//Procedure Manche(var liste:joueursArray;n:integer);
//Procedure Ascendant(liste:joueursArray);
//Procedure Descendant(liste:joueursArray);
Procedure ComptageDePoint(var liste:joueursArray);
function creerjoueur(couleur:byte;colorname:string):joueur;
procedure creerjoueurs(var liste:joueursArray);
//Procedure Partie(var liste:joueursArray);

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
Procedure Parions(var liste:joueurs;n:integer;var s,m:integer); //n:nb de cartes par joueur, s:somme des paris et m:nb max qu'il reste à parier
var i,k:integer;
begin
	k:=-1;
	If (liste.bot=false) then
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
	liste.pari:=k;
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

// x = nbr de cartes par joueur 
Function InitAtout(liste:joueursArray;x:integer):carte;
var k:carte;
begin
Distribuer(liste,x);
Repeat
	k:=d[random(52)];
until VerifAtout(liste,k);
InitAtout:=k;
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

//Fonction qui renvoit le numéro du joueur dont la carte remporte le pli
Function BestPli(T:array of carte;atout:carte):integer;
var i,best:integer;
begin
	best:=0; //initialisation à la première carte du pli
	For i:=0 to high(T) do
	begin
		If (T[i].couleur=T[0].couleur) then
		begin
			If (T[i].couleur=T[best].couleur) then
				If (T[i].valeur>T[best].valeur) then best:=i; //si atout pas encore posé
		end
		Else
		begin
			If (T[i].couleur=atout.couleur) then  
			begin
				If T[i].couleur=T[best].couleur then //si atout déjà posé
				begin
					If (T[i].valeur>T[best].valeur) then best:=i;
				end
				Else best:=i; //premier atout posé
			end;
		end;
	end;
	Exit(best);
end;

// Procédure permettant d'afficher l'ordre des joueurs pour le pli suivant.
Procedure OrdreJoueur(var liste:joueursArray;atout:carte;C:Array of carte);
var i,j,x:integer;
T:joueursArray;
begin
	setlength(T,high(liste)+1);
	T[0]:=liste[BestPli(C,atout)];
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

// n est le nombre de carte distribuer par joueur
Procedure ComptageDePoint(var liste:joueursArray);
var i:integer; 
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

begin
	d:=init;
end.
