unit in0k_lazExt_AFC_synEdit;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils,
  SynEdit, SynEditHighlighterFoldBase, SynHighlighterPas;

type

  {inkDoc> "представитель" synEdit`а
    Существование этого класса обусловленно необходимостью доступа к свойству
    `TCustomSynEdit.TextView`, которое "скрыто" в `TSynEdit`.
  <inkDoc}
 tIn0k_lazExt_AFC_synEdit=class(TCustomSynEdit)
  protected
    function _FldInf_isCommentForProcessing(const FldInf:TSynFoldNodeInfo):boolean; inline;
  public
    procedure foldComments_ALL;
    procedure foldComments_Name(const names:tStrings);
  end;

implementation

function tIn0k_lazExt_AFC_synEdit._FldInf_isCommentForProcessing(const FldInf:TSynFoldNodeInfo):boolean;
begin
    result:=(TPascalCodeFoldBlockType({%H-}PtrUInt(FldInf.FoldType)) in
              [cfbtAnsiComment, cfbtBorCommand, cfbtSlashComment]
            ) AND (sfaFoldFold in FldInf.FoldAction)
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{TODO: Разобраться с методом обхода "комментариев".
    Скорее всего есть более элегантный способ обхода ВСЕХ комментариев готовых
    к сворачиванию. Хоть подход и взят из "официального"
    (`TIDESynGutterCodeFolding.PopClickedFoldComment`)
    мне он НЕ кажется оптимальным.
:TODO}

{inkDoc> Свернуть ВСЕ и ВСЁ                                              <
    свернуть ВСЕ сомментарии, которые встретим
<inkDoc}
procedure tIn0k_lazExt_AFC_synEdit.foldComments_ALL;
var i, j:integer;
  FldInf:TSynFoldNodeInfo;
begin
    for i:=0 to Lines.Count-1 do begin
        j:=TextView.FoldProvider.FoldOpenCount(i);
        while j > 0 do begin
            dec(j);
            FldInf:=TextView.FoldProvider.FoldOpenInfo(i,j);
            if _FldInf_isCommentForProcessing(FldInf) then begin
                TextView.FoldAtTextIndex(i,j,1,False,1);
            end;
        end;
    end;
end;

{inkDoc> Свернуть выборочно                                              <
    свернуть только ТЕ комментарии, в которых в ПЕРВОЙ строке найдется "слово"
    из списка `names`
    @prm(names список "слов")
<inkDoc}
procedure tIn0k_lazExt_AFC_synEdit.foldComments_Name(const names:tStrings);
var i, j:integer;
  FldInf:TSynFoldNodeInfo;
var    k:integer;
       s:string;
begin
  if (names<>nil)and(names.Count>0) then
    for i:=0 to Lines.Count-1 do begin
        j:=TextView.FoldProvider.FoldOpenCount(i);
        while j > 0 do begin
            dec(j);
            FldInf:=TextView.FoldProvider.FoldOpenInfo(i,j);
            if _FldInf_isCommentForProcessing(FldInf) then begin
                s:=UpperCase(Lines[i]);
                for k:=0 to names.Count-1 do begin
                    if pos(names.Strings[k],s)>0
                    then TextView.FoldAtTextIndex(i,j,1,False,1);
                end;
            end;
        end;
    end;
end;

end.

