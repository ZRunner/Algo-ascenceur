UNIT Bot;

interface
USES fpjson, jsonparser, Intro, graph, classes, Crt, sysutils;

implementation
CONST pseudos : array[0..3] of string = ('Panda','Couscous','Manhattan','Cyan');

Function CreerBot():joueur;
Var 
begin
	randomize;
	creerBot.pseudo := pseudos[round(random(4))];
end;


END.
