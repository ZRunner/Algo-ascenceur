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
end; // deux autres procedures du même principe pour gagnant nouveau pli et nouvelle manche 

//pour un tour
Procedure Pli(var liste:joueurs);
var i:integer;
begin
	For i:=0 to high(liste) do
	begin
		
	end;
end;

//pour une manche
Procedure Manche(var liste:joueurs;n:integer);
var i,j:integer;
begin
	Parions(liste,n);
	For i:=2 to n do //premier joueur = gagnant tour précédent
	begin
		Pli(liste);
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

var i,nb:integer; liste:joueurs;
begin
	nb:=InitJoueur();
end.
