UNIT Bot;

interface

USES Intro, graph, classes, Crt, sysutils, deroulement;

implementation

CONST pseudos : array[0..4] of string = ('Panda','Couscous','Manhattan','Cyan','Axolotl');
var conf : classes.config;

Function CreerBot():joueur;
begin
	randomize;
	creerBot.pseudo := pseudos[round(random(5))];
	creerBot.age := random(80)+8;
	creerBot.bot := true;
end;

Procedure PartieBot(n:integer; var liste:joueursArray); //n nombre de joueurs déjà enregistrés
var nb,i:integer;
begin
	nb:=conf.players; 
	while (nb+n>conf.players) do
	begin
		Writeln('Combien voulez-vous d''IA?');
		Readln(nb)
	end;
	For i := n+1 to n+nb do
		liste[i] := CreerBot();
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
 	If j<>0 Then
		ChoixCarteCouleurBot:=T[round(random(length(T)))]
	Else
		ChoixCarteCouleurBot:=packet.cartes[random(length(packet.cartes))];
end;

Function ChoixCarteBotPrems(packet:joueur):carte;
Begin
	ChoixCarteBotPrems:=packet.cartes[random(length(packet.cartes))];
end;


END.
