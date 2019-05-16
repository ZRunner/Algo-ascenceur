program Projet;

uses fpjson, jsonparser, Crt;


Type carte = Record
    couleur:string;
    valeur:integer;
    end;

Type joueur=Record
    cartes:array of carte;
    pseudo:string;
    age:integer;
    couleur:byte;
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
    for i:=0 to high(liste) do
        if (liste[i].couleur = card.couleur) and (liste[i].valeur = card.valeur) then Exit(True);
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

// Cette fonction pourra facilement être changée lorsqu'on entamera la partie graphique
procedure display_text(a:string);
begin
    writeln(a)
end;

// Chargement de la configuration du jeu
function loadconfig:config;
var jData:TJSONData;
    jObject : TJSONObject;
begin
    jData := GetJSON('{"max_players":5,"win_default":10,"win":2,"loose":-2,"min_age":5,"max_age":100}');
    jObject := TJSONObject(jData);
    loadconfig.players := jObject.Get('max_players');
    loadconfig.win_defaut := jObject.Get('win_default');
    loadconfig.win := jObject.Get('win');
    loadconfig.loose := jObject.Get('loose');
    loadconfig.min_age := jObject.Get('min_age');
    loadconfig.max_age := jObject.Get('max_age');
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
    writeln;
end;

// Création de la liste de tous les joueurs
procedure creerjoueurs(var liste:joueurs);
var i:integer;
    cls:array[0..4] of byte=(red,yellow,blue,green,,LightMagenta,Brown,White);
    clsn:array[0..4] of string=('Rouge','Jaune','Bleu','Vert','Violet','Marron','Blanc');
begin
    for i:=0 to high(liste) do
        liste[i] := creerjoueur(cls[i],clsn[i]);
    normvideo;
end;

procedure distribuer(var liste:joueurs;n:integer);
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

procedure partie(liste:joueurs);
var c:carte;
begin
    distribuer(liste,5);
    c := liste[0].cartes[0];
end;



begin
    randomize;
    d := init;
    conf := loadconfig;
    setlength(liste,conf.players);
    creerjoueurs(liste);
    partie(liste);
end.
