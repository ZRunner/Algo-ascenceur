UNIT Intro;

interface
PROCEDURE Demande();

implementation

PROCEDURE LireIntro(); 
VAR fic:text; ligne:string;
BEGIN
	ligne:='';
	{$i-}
	assign(fic,'IntroJeu.txt');
	reset(fic);
	if (IOResult <> 0) Then Exit
	Else
	begin
		repeat
			writeln(ligne);
			readln(fic, ligne);
		until eof(fic);
		close(fic);
	end;
END;

PROCEDURE Demande();
VAR choix:char;
BEGIN
	Writeln('Voulez-vous lire les règles ? (o:oui, n:non)');
	readln(choix);
	If choix='o' Then LireIntro();
END;


END.
