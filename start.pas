program Projet;

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

// Lecture d'un fichier (celui de config)
function loadfile(nom:string):unicodestring;
var fic:text;
    ligne:unicodestring;
begin
    ligne := '';
    loadfile := '';
    { $i- }
    assign(fic,nom);
    reset(fic);
    if IOResult<>0 then Exit('');
    repeat
        readln(fic,ligne);
        ligne := Trim(ligne);
        loadfile := loadfile+ligne;
    until eof(fic);
    close(fic);
end;

// Chargement de la configuration du jeu
function loadconfig:config;
var jData:TJSONData;
    jObject : TJSONObject;
begin
    jData := GetJSON(loadfile('config.json'));
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
    cls:array[0..6] of byte=(red,yellow,blue,green,Magenta,Brown,LightGray);
    clsn:array[0..6] of string=('Rouge','Jaune','Bleu','Vert','Violet','Marron','Blanc');
begin
    for i:=0 to high(liste) do
        liste[i] := creerjoueur(cls[i],clsn[i]);
    normvideo;
end;

// Distribue un certain nombre de cartes aux joueurs, selon le deck de base
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

// Fonction globale de la partie, qui va appeller toutes les autres
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
    Demande();
end.
