unit in0k_lazExt_AFC_synEdit;

{$mode objfpc}{$H+}

interface

uses {$ifOpt D+} in0k_lazExt_AFC_wndDBG,  SysUtils, {$endIf}

Classes,   FindDeclarationTool,CodeToolManager, CodeCache,
    SynEdit,
    SynEditHighlighterFoldBase,
    SynEditFoldedView,
    SynHighlighterPas,
    in0k_lazExt_HFC_core,

    SrcEditorIntf;

type

  {inkDoc> "представитель" synEdit`а
    Существование этого класса обусловленно необходимостью доступа к свойству
    `TCustomSynEdit.TextView`, которое "скрыто" в `TSynEdit`.
  <inkDoc}
 tIn0k_lazExt_AFC_synEdit=class(TCustomSynEdit)
  protected
    function _FldInf_isCommentForProcessing(const FldInf:TSynFoldNodeInfo):boolean; inline;
  protected
    function _mastFold_byNames(const names:tStrings; const txt_InUpCASE:string):boolean;

  protected
    procedure _FoldAtTextIndex(const FldInf:TSynFoldNodeInfo; const idLine,idFold:integer);
  public
    procedure foldComments_ALL;
    procedure foldComments_Name(const CodeBuffer:TCodeBuffer; const names:tStrings; const fold_HFC:boolean);
  end;

implementation

{docHint> подходит ли FoldNode под параметры "для сворачивания"          <
    ~prm FldInf что именно проверяем
    ~ret true да, это комментарий и его можно свернуть
<docHint}
function tIn0k_lazExt_AFC_synEdit._FldInf_isCommentForProcessing(const FldInf:TSynFoldNodeInfo):boolean;
begin
    result:=(TPascalCodeFoldBlockType({%H-}PtrUInt(FldInf.FoldType)) in
              [cfbtAnsiComment, cfbtBorCommand, cfbtSlashComment]
            ) AND (sfaFoldFold in FldInf.FoldAction)
end;



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tIn0k_lazExt_AFC_synEdit._FoldAtTextIndex(const FldInf:TSynFoldNodeInfo; const idLine,idFold:integer);
begin
    {$ifOpt D+}
   _dbgLOG_('fold :-> idLine='+inttostr(idLine)+' idFold='+inttostr(idFold) +
                    ' Column='+inttostr(FldInf.LogXStart+1)+' ColLEN='+inttostr(FldInf.LogXEnd-FldInf.LogXStart));
    {$endIf}
    {TODO: надо бы поразбираться с этим вызовом (с этим семейством вызовов)}
    TextView.FoldAtTextIndex(idLine,idFold,1,False,1)
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{TODO: Разобраться с методом обхода "комментариев".
    Скорее всего есть более элегантный способ обхода ВСЕХ комментариев готовых
    к сворачиванию. Хоть подход и взят из "официального"
    (`TIDESynGutterCodeFolding.PopClickedFoldComment`)
    мне он НЕ кажется оптимальным.
:TODO}

{docHint> Свернуть ВСЕ и ВСЁ                                             <
    свернуть ВСЕ сомментарии, которые встретим
<docHint}
procedure tIn0k_lazExt_AFC_synEdit.foldComments_ALL;
var idLine:integer;
    idFold:integer;
    FldInf:TSynFoldNodeInfo;
begin
    {$ifOpt D+}
   _dbgLOG_('foldComments_ALL ->');
    {$endIf}
    for idLine:=0 to Lines.Count-1 do begin
        idFold:=TextView.FoldProvider.FoldOpenCount(idLine); //< кол-во груп начинающихся в строке
        while idFold > 0 do begin
            dec(idFold);
            FldInf:=TextView.FoldProvider.FoldOpenInfo(idLine,idFold);
            if _FldInf_isCommentForProcessing(FldInf) then begin
               _FoldAtTextIndex(FldInf,idLine,idFold);
            end;
        end;
    end;
end;

{docHint> Свернуть выборочно                                             <
    Cвернуть только ТЕ комментарии, в которых в ПЕРВОЙ строке найдется "слово"
    из списка `names`.
    ~prm names    список "слов"
    ~prm fold_HFC так же сворачивать "Hint From Comment"
<docHint}
procedure tIn0k_lazExt_AFC_synEdit.foldComments_Name(const CodeBuffer:TCodeBuffer; const names:tStrings; const fold_HFC:boolean);
var idLine:integer;
    idFold:integer;
    FldInf:TSynFoldNodeInfo;
    PrvInf:TSynEditFoldProviderNodeInfo;
begin
    {$ifOpt D+}
   _dbgLOG_('foldComments_NMS ->');
    {$endIf}
    if ((names<>nil)and(names.Count>0)) //< эту проверку надо ИЗНИЧТОЖИТЬ
        or(fold_HFC)
    then begin
        for idLine:=0 to Lines.Count-1 do begin
            idFold:=TextView.FoldProvider.FoldOpenCount(idLine); //< кол-во груп начинающихся в строке
            while idFold > 0 do begin
                dec(idFold);
                FldInf:=TextView.FoldProvider.FoldOpenInfo(idLine,idFold);
                //PrvInf:=TextView.FoldProvider.InfoForFoldAtTextIndex(idLine,idFold);
                if _FldInf_isCommentForProcessing(FldInf) then begin
                    if ((names.Count>0)and(_mastFold_byNames(names,UpperCase(Lines[idLine]))))
                      or
                       ((fold_HFC)and (in0k_lazExt_HFC__getOwnerAtomINDEX(CodeBuffer,@FldInf)>0 ))
                    then begin
                        _FoldAtTextIndex(FldInf,idLine,idFold);
                    end;
                end;
            end;
        end;
    end;
end;

{docHint> попадает ли строка в "условия-сворачивания-names"              <
    Проверка, есть ли в строке хоть одно слова из списка.
    ~prm names список "слов"
    ~prm txt_InUpCASE тестируемая строка !!! в ВЕРХНЕМ регистре
<docHint}
function tIn0k_lazExt_AFC_synEdit._mastFold_byNames(const names:tStrings; const txt_InUpCASE:string):boolean;
var i:integer;
begin
    result:=false;
    for i:=0 to names.Count-1 do begin
        if pos(names.Strings[i],txt_InUpCASE)>0
        then begin
            result:=true;
            break
        end;
    end;
end;

end.

