program Projet;

uses fpjson, jsonparser;


Type carte = Record
    couleur:string;
    valeur:integer;
    end;

Type joueur=Record
    cartes:array of carte;
    pseudo:string;
    age:integer;
    end;

Type config = Record
    players:integer;
    win_defaut:integer;
    win:integer;
    loose:integer;
    min_age:integer;
    max_age:integer
    end;

Type deck = array[0..51] of carte;
Type joueurs=array of joueur;

var d:deck;
    liste:joueurs;
    conf:config;


function inarray(liste:array of carte;card:carte):boolean;
var i:integer;
begin
    for i:=0 to length(liste) do
        if (liste[1].couleur = card.couleur) and (liste[1].valeur = card.valeur) then Exit(True);
    Exit(False);
end;

function init:deck;
var i,j:integer;
    couleur:string;
    cs:array[0..3] of string=('carreau','pique','trèfle','coeur');
begin
    j := 0;
    for couleur in cs do
        for i:=2 to 14 do begin
            init[j].couleur := couleur;
            init[j].valeur := i;
            j := j+1;
            end;
end;

function loadconfig:config;
var jData:TJSONData;
    jObject : TJSONObject;
begin
    jData := GetJSON('{"max_players":4,"win_default":10,"win":2,"loose":-2,"min_age":5,"max_age":100}');
    jObject := TJSONObject(jData);
    loadconfig.players := jObject.Get('max_players');
    loadconfig.win_defaut := jObject.Get('win_default');
    loadconfig.win := jObject.Get('win');
    loadconfig.loose := jObject.Get('loose');
    loadconfig.min_age := jObject.Get('min_age');
    loadconfig.max_age := jObject.Get('max_age');
end;



function creerjoueur:joueur;
var age:integer;pseudo:string;
begin
    write('Indiquez votre pseudo',#10,'> ');readln(pseudo);
    write('Indiquez votre âge',#10,'> ');readln(age);
    while (conf.min_age>age) or (age>conf.max_age) do begin
        write('Indiquez votre âge',#10,'> ');readln(age);
    end;
    creerjoueur.age := age;
    creerjoueur.pseudo := pseudo;
end;

procedure creerjoueurs(var liste:joueurs);
var i:integer;
begin
    for i:=0 to high(liste) do
        liste[i] := creerjoueur;
end;

procedure distribuer(var liste:joueurs;n:integer);
var i,j,k,p:integer;
    utilises:deck;
begin
    k := 0;
    for p:=0 to high(liste) do begin
        setlength(liste[p].cartes,n);
        j := 0;
        for i:=0 to n do begin
            liste[p].cartes[j] := d[random(52)];
            while inarray(utilises,liste[p].cartes[j]) do
                liste[p].cartes[j] := d[random(52)];
            utilises[k] := liste[p].cartes[j];
            j := j+1;
            k := k+1;
            end;
        end;
end;

procedure partie(liste:joueurs);
begin
    distribuer(liste,5);
    writeln(liste[0].cartes[0].couleur,' ',liste[0].cartes[0].valeur);
end;



begin
    randomize;
    d := init;
    conf := loadconfig;
    setlength(liste,conf.players);
    creerjoueurs(liste);
    writeln(d[0].couleur,' ',d[0].valeur);
    writeln(d[32].couleur,' ',d[32].valeur);
    writeln(d[51].couleur,' ',d[51].valeur);
    partie(liste);
end.
