Program ProjetAscenseur;
uses deroulement,loadconfig,Intro,classes,Bot,sysutils,graph,crt;
var conf=config;
liste=joueursarray;

Begin
  randomize;
  Demande();
  conf:=loadconfig('config.txt');
  Partie(liste);
end;
