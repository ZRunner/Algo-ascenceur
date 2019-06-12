UNIT Bot;

interface
USES fpjson, jsonparser, Intro, graph, classes, Crt, sysutils;

implementation
CONST pseudos : array[0..3] of string = ('Panda','Couscous','Manhattan','Cyan','Axolotl');

Function CreerBot():joueur;
Var
begin
	randomize;
	creerBot.pseudo := pseudos[round(random(5))];
end;


END.
