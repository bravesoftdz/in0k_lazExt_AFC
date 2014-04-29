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
    procedure _FOLD_FldInf   (const FldInf:TSynFoldNodeInfo; const idFold:integer); inline;
  protected
    function _mastFold_mstPRC(const FldInf:TSynFoldNodeInfo):boolean; inline;
    function _mastFold_by_LST(const FldInf:TSynFoldNodeInfo; const names:tStrings):boolean;
    function _mastFold_by_HFC(const FldInf:TSynFoldNodeInfo; const CodeBuffer:TCodeBuffer; var useHFC:boolean):boolean;
  public
    procedure foldComments_ALL;
    procedure foldComments_Name(const names:TStrings; const CodeBuffer:TCodeBuffer);
  end;

implementation

{docHint> слопнуть                                                       <
    ~prm FldInf что именно сворачиваем
    ~prm idFold чиста для дебага
<docHint}
procedure tIn0k_lazExt_AFC_synEdit._FOLD__FldInf(const FldInf:TSynFoldNodeInfo; const idFold:integer);
begin
    {$ifOpt D+}
   _dbgLOG_('fold :-> idLine='+inttostr(FldInf.LineIndex+1)+' idFold='+inttostr(idFold) +
                    ' Column='+inttostr(FldInf.LogXStart+1)+' ColLEN='+inttostr(FldInf.LogXEnd-FldInf.LogXStart));
    {$endIf}
    {TODO: надо бы поразбираться с этим вызовом (с этим семейством вызовов)}
    TextView.FoldAtTextIndex(FldInf.LineIndex,idFold,1,False,1)
end;

//------------------------------------------------------------------------------

{TODO: Разобраться с методом обхода "комментариев".
   Скорее всего есть более элегантный способ обхода ВСЕХ комментариев готовых
   к сворачиванию. Хоть подход и взят из "официального"
   (`TIDESynGutterCodeFolding.PopClickedFoldComment`)
   мне он НЕ кажется оптимальным, так как используем ПРЯМОЙ проход по строкам
   исходника, что не есть хорошо.

   см. методы `foldComments_ALL`, `foldComments_Name`
   ~src~
       for idLine:=0 to Lines.Count-1 do begin
           idFold:=TextView.FoldProvider.FoldOpenCount(idLine); //< кол-во груп начинающихся в строке
           while idFold > 0 do begin
               dec(idFold);
               FldInf:=TextView.FoldProvider.FoldOpenInfo(idLine,idFold);
               ...
           end;
       end;
   ~~~~~
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
            if _mastFold_mstPRC(FldInf)
            then _FOLD__FldInf(FldInf,idLine,idFold);
        end;
    end;
end;

{docHint> Свернуть выборочно                                             <
    Cвернуть только ТЕ комментарии, в которых в ПЕРВОЙ строке найдется "слово"
    из списка `names`.
    ~prm names    список "слов"
    ~prm fold_HFC так же сворачивать "Hint From Comment"
<docHint}
procedure tIn0k_lazExt_AFC_synEdit.foldComments_Name(const names:TStrings; const CodeBuffer:TCodeBuffer);
var idLine:integer;
    idFold:integer;
    FldInf:TSynFoldNodeInfo;
 _use_HTC :boolean; //< использовать ли проверку (если файл НЕможем построить дерево то эта проверка НЕ работает)
 _mastFold:boolean;
begin
    {$ifOpt D+}
   _dbgLOG_('foldComments_NMS ->');
    {$endIf}
    if (Assigned(CodeBuffer)) OR (Assigned(names)and(names.Count>0)) then begin
       _use_HTC:=Assigned(CodeBuffer);

        for idLine:=0 to Lines.Count-1 do begin
            idFold:=TextView.FoldProvider.FoldOpenCount(idLine); //< кол-во груп начинающихся в строке
            while idFold > 0 do begin
                dec(idFold);
                FldInf:=TextView.FoldProvider.FoldOpenInfo(idLine,idFold);
                if _mastFold_mstPRC(FldInf) then begin
                    // нужно решать, сворачивать или нет
                    if _mastFold_by_LST(@FldInf,names)
                       or
                       _mastFold_by_HFC(@FldInf,CodeBuffer,_use_HTC)
                    then begin
                       _FOLD__FldInf(FldInf,idLine,idFold);
                    end;
                end;
            end;
        end;
    end;
end;

//------------------------------------------------------------------------------

{docHint> должно быть проверенно на предмет СВОРАЧИВАНИЯ                 <
    ~prm FldInf что именно проверяем
    ~ret true да, это комментарий и его можно свернуть => проверять
<docHint}
function tIn0k_lazExt_AFC_synEdit._mastFold_mstPRC(const FldInf:TSynFoldNodeInfo):boolean;
begin
    result:=(TPascalCodeFoldBlockType({%H-}PtrUInt(FldInf.FoldType)) in
              [cfbtAnsiComment, cfbtBorCommand, cfbtSlashComment]
            ) AND (sfaFoldFold in FldInf.FoldAction)
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{docHint> попадает ли строка в "условия-сворачивания-names"              <
    Проверка, есть ли в строке хоть одно слова из списка.
    ~prm FldInf что именно проверяем
    ~prm names список "слов"
<docHint}
function tIn0k_lazExt_AFC_synEdit._mastFold_by_LST(const FldInf:pSynFoldNodeInfo; const names:tStrings):boolean;
var s:string;
    i:integer;
begin
    result:=false;
    if Assigned(names) and (names.Count>0) then begin
        // готовим строку к поиску
        s:=Lines[FldInf^.LineIndex];
        delete(s,1,FldInf^.LogXStart);
        s:=trim(s);
        // проводим поиск по списку
        if s<>'' then begin
            s:=UpperCase(s); //< исчем по строке в ВЕРХНЕМ регистре !!!
            for i:=0 to names.Count-1 do begin
                if pos(names.Strings[i],s)>0
                then begin
                    {$ifOpt D+}
                   _dbgLOG_('find NAME: "'+names.Strings[i]+'"');
                    {$endIf}
                    result:=true;
                    break
                end;
            end;
        end;
    end;
end;

{docHint> попадает ли строка в "Hint From Comment"                       <
    ~prm FldInf что именно проверяем
    ~prm names список "слов"
<docHint}
function tIn0k_lazExt_AFC_synEdit._mastFold_by_HFC(const FldInf:pSynFoldNodeInfo; const CodeBuffer:TCodeBuffer; var useHFC:boolean):boolean;
var i:integer;
begin
    {*/fold  самом деле алгоритм иногда ошибается
    **  в реальности можно сделать более точнее, однако и более затратнее по
    **  ресурсам (что может привести к затормаживанию интерфейса):
    **    #1 получив номер AtomINDEX запросить для него HitFromComment (который
    **        выдаст список ВСЕХ блоков комментариев входящих в состав)
    **    #2 проверить что FldInf попадает в этот список, и тока в этом случае
    **        сворачивать
    **  ~~~
    **  может в будущем, если текуший вариант не устроит
    *}
    result:=useHFC;
    if result then begin
        i:=in0k_lazExt_HFC__getOwnerAtomINDEX(CodeBuffer,FldInf);
        if i>0 then begin
            // по сути: нашли к чему этот комментарий
            result:=true;
            {$ifOpt D+}
           _dbgLOG_('find HFC: atomINDEX='+inttostr(i));
            {$endIf}
        end
        else begin
            result:=false;//< ничего не нашли ...
            if i<-10 then begin //< или КРИТИЧЕСКАЯ ошибка разбора исходника
                // то.есть некий косяк в исходнике, который НЕ позволяет его
                // проанализировать и построить дерево-рабора. => НЕ ПРОВЕРЯТЬ
                useHFC:=FALSE;
                {$ifOpt D+}
               _dbgLOG_('find HFC: OFF '+inttostr(i));
                {$endIf}
            end;
        end;
    end;
end;

end.

