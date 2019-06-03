Program UnePartie;

uses fpjson, jsonparser, Intro, Crt, sysutils;


Type carte = Record // L'une des 52 cartes du jeu
    couleur:string;
    valeur:integer;
    end;

Type joueur=Record // L'un des joueurs
    cartes:array of carte;
    pseudo:string;
    age:integer;
    couleur:byte;
    pari:integer;
    point:integer;
    end;

Type config = Record // configuration de la partie
    players:integer;
    win_defaut:integer;
    win:integer;
    loose:integer;
    min_age:integer;
    max_age:integer
    end;

Type deck = array[0..51] of carte; // Liste de toutes les cartes du jeu, triées
Type joueurs=array of joueur; // Liste de tous les joueurs du jeu

var d:deck;
    liste:joueurs;
    conf:config;

//initialise le nombre de joueurs
Function InitJoueur():integer; 
var n:integer;
begin
	writeln('Combien de joueurs êtes-vous?');
	readln(n);
	Exit(n);
end;

// Vérifie si une carte se trouve dans une liste de cartes
function inarray(liste:array of carte;card:carte):boolean;
var i:integer;
begin
    for i:=0 to high(liste) do
        if (liste[i].couleur = card.couleur) and (liste[i].valeur = card.valeur) then Exit(True);
    Exit(False);
end;

// Initialise le jeu, en créant le paquet de cartes
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
procedure distribuer(var liste:joueurs;n:integer);
var i,k,p:integer;
    utilises:deck;
begin
    k := 0;
    for p:=0 to high(liste) do begin
        setlength(liste[p].cartes,n);
        for i:=0 to n-1 do begin
            liste[p].cartes[i] := d[random(52)];  //c quoi le d?
            while inarray(utilises,liste[p].cartes[i]) do
                liste[p].cartes[i] := d[random(52)];
            utilises[k] := liste[p].cartes[i];
            k := k+1;
            end;
        end;
end;

//enregistrement des paris
Procedure Parions(var liste:joueurs;n:integer);
var i,k,s,m:integer;
begin
	s:=0;
	m:=n+1;
	For i:=0 to high(liste) do
	begin
		k:=-1;
		While (k<0) or (k>m) do
		begin
			writeln('Combien de plis pensez-vous réaliser ?');
			readln(k);
		end;
		liste[i].pari:=k;
		s:=s+k;
		m:=m-s;
	end;
end;

//changer la liste avec le premier joueur premier liste au début de la partie
Procedure plusJeune(var liste:joueurs); 
var i,j,x:integer; T:joueurs;
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

Function RandomDeck:deck
var p:deck
Begin
 k := 0;
        for i:=0 to 51 do begin
            p[i] := d[random(52)];         
            while inarray(utilises,p[i]) do
                p[i] := d[random(52)];
            utilises[k] := p[i];
            k := k+1;
		end;
end;

Function InitAtout(liste:joueurs,n:integer):carte; // n= nbr de cartes par joueur et p=nombre de players
var d:deck;
p:integer;
j,i:integer;
T: array of carte;
begin
d:=Randomdeck;
p:=InitJoueur();
Distribuer(liste,p);
i:=n*p-1;
Setlength(T,n*p);
For j:=0 to n*p-1 do
Begin
	While (i-n*p-1<=n*p-1) do
		Begin
		T[j]:=d[i];
		i:=i+1;
		end;
end;
Atout:=T[0];
end;

Procedure NombreManche(var conf:config); // Calcule le nombre de manches dans une partie en fonction du nombre de joueurs.
begin
conf.players:=InitJoueur();
nbrManche:=round(52/i);
If (conf.players=2) or (conf.players=4) then 
 nbrManche:=nbrManche-1;
end;

//Faire une procédure permettant de réaliser tout les plis de la manche.

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
		if choix=paquet.cartes[i] Then VerifieCarteAjoueur:=true;
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

//pour un tour, renvoit un entier qui est le numéro du gagnant dans la liste actuelle
Function Pli(var liste:joueurs; atout:string):integer;
var i:integer; T:array of carte; choix:carte; best:integer;
begin
	T[0]:=ChoixCarte(liste[0].cartes);
	best:=0;
	For i:=1 to high(liste) do
	begin
		Repeat 
			choix:=ChoixCarte(liste[i].cartes); //choix est dans le paquet du joueur	
		Until VerifDroitDePoser(liste[i],choix,T[0]); 
		T[i]:=choix;
		If (T[i].couleur=T[i-1].couleur) and (T[i].valeur>T[i-1].valeur) Then best:=i; 
		//à rajouter comparaison avec l'atout
	end;
	Exit(best);
end;

//Function retrouvant dans la liste le pseudo du gagnant.
Function RecherchePseudoGagnant(liste:joueurs,atout:string):joueur; 
var i: integer;
begin
For i:=1 to high(liste) do 
	If Pli(liste,atout):= i then
	Exit(liste[i]);
end;

// Procédure permettant d'afficher l'ordre des joueurs pour le pli suivant. 
Procedure OrdreJoueur(var liste:joueurs;atout:string); 
var i,j,x:integer;
T:joueurs;
begin
	setlength(T,high(liste)+1);
	T[0]:=RecherchePseudoGagnant(liste,atout);
	For i:=1 to high(liste) do
		If T[0]=liste[i] Then x:=i;
	j:=x+1;
	For i:=1 to high(T) do
	begin
		T[i]:=liste[j];
		j:=j+1;
		if j=high(liste) then j:=0
	end;
end;

//pour une manche
Procedure Manche(var liste:joueurs;n:integer);
var i,j:integer; atout:string;
begin
	atout:=InitAtout(liste,n);
	Parions(liste,n);
	For i:=2 to n do //premier joueur = gagnant tour précédent
	begin
		OrdreJoueur(liste,atout);
	end;
end;

//la phase ascendante
Procedure Ascendant(liste:joueurs);
var i:integer;
begin
	For i:=1 to x do
	begin
		distribuer(liste,i);
		Manche(liste,i);
	end;
		
end;

//la phase descendante
Procedure Descendant(liste:joueurs);
var i:integer;
begin
	For i:=x downto 1 do
	begin
		distribuer(liste,i);
		Manche(liste,i);
	end;
end;

var i,nb:integer; liste:joueurs;
begin
	nb:=InitJoueur();
end.
