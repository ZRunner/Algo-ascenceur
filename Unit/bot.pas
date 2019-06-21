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
	repeat
		Writeln('Combien voulez-vous d''IA?');
		Readln(nb)
	until(nb+n<=conf.players);
	For i := n+1 to n+nb do
		liste[i] := CreerBot();
end;



END.
