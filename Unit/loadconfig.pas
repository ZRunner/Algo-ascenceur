Unit loadconfig;

{$mode objfpc}


// ---------- PUBLIC ----------- //

interface

uses classes, sysutils;

function loadconf(fichier:string='config.txt'):classes.config;



// ---------- PRIVE ------------ //

implementation

function loadconf(fichier:string='config.txt'):classes.config;
var fic:text;
    ligne:unicodestring;
    opt,val:string;
    c:char;
    is_opt:boolean;
begin
    ligne := '';
    { $i- }
    assign(fic,fichier);
    reset(fic);
    if IOResult<>0 then Exit;
    repeat
        is_opt := True;
        opt := ''; val := '';
        readln(fic,ligne);
        ligne := Trim(ligne);
        for c in ligne do
            if c=':' then
                is_opt := False
            else if is_opt then
                opt += c
            else
                val += c;
        case opt of
            'max_players' : loadconf.players := StrToInt(val);
            'win_default' : loadconf.win_defaut := StrToInt(val);
            'win' : loadconf.win := StrToInt(val);
            'loose' : loadconf.loose := StrToInt(val);
            'min_age' : loadconf.min_age := StrToInt(val);
            'default_window' : loadconf.default_window_size := StrToInt(val);
            'max_age' : loadconf.max_age := StrToInt(val);
        end;
    until eof(fic);
    close(fic);
end;

end.
