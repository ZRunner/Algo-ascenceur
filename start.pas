program Projet;

uses loadconfig, Intro, Crt, sysutils, classes;


var d:deck;
    liste:joueursArray;
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

// Création d'un joueur, avec son pseudo, sa couleur et son age
function creerjoueur(couleur:byte;colorname:string):joueur;
var age:integer;pseudo:string;ok:boolean;
begin
    writeln(conf.min_age,' ',conf.max_age);
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
procedure creerjoueurs(var liste:joueursArray);
var i:integer;
    cls:array[0..6] of byte=(red,yellow,blue,green,Magenta,Brown,LightGray);
    clsn:array[0..6] of string=('Rouge','Jaune','Bleu','Vert','Violet','Marron','Blanc');
begin
    for i:=0 to high(liste) do
        liste[i] := creerjoueur(cls[i],clsn[i]);
    normvideo;
end;


// Distribue un certain nombre de cartes aux joueurs, selon le deck de base
procedure distribuer(var liste:joueursArray;n:integer);
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
procedure partie(liste:joueursArray);
var c:carte;
begin
    distribuer(liste,5);
    c := liste[0].cartes[0];
end;


begin
    randomize;
    d := init;
    conf := loadconfig.loadconfig('config.txt');
    setlength(liste,conf.players);
    creerjoueurs(liste);
    partie(liste);
    Demande();
end.
