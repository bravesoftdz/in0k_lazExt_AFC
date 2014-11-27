unit AFC_Config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type


 rAFC_Config_Object=record
   _workList:tStrings; //< реально работающий список "Имен" (upCASE)
   _nameList:tStrings; //< список "Имен"
   _lazExtON:boolean;  //< мы вообще работаем
   _fold_ALL:boolean;  //< сворачивать ВСЕ
   _fold_LST:boolean;  //< сворачивать использовать списки
   _fold_HFC:boolean;  //< сворачивать Hint From Comment
  end;
 pAFC_Config_Object=^rAFC_Config_Object;

function  AFC_Config_Object__CRT:pAFC_Config_Object;
procedure AFC_Config_Object__DST(const CFG:pAFC_Config_Object);
procedure AFC_Config_Object__DEF(const CFG:pAFC_Config_Object);

procedure AFC_Config_Object__nameList_LOAD(const CFG:pAFC_Config_Object; const names:tStrings);
procedure AFC_Config_Object__nameList_SAVE(const CFG:pAFC_Config_Object; const names:tStrings);

implementation

const //< настройки по УМОЛЧАНИЮ
   cIn0k_lazExt_AFN_defVAL_ExtnsnON=TRUE;     //<
   cIn0k_lazExt_AFN_defVAL_fold_ALL=false;    //<
   cIn0k_lazExt_AFN_defVAL_fold_LST=true;     //<
   cIn0k_lazExt_AFN_defVAL_fold_HFC=true;     //<
   cIn0k_lazExt_AFN_defVAL_lst_FOLD='fold';
   cIn0k_lazExt_AFN_defVAL_lst_TODO='todo';


function  AFC_Config_Object__CRT:pAFC_Config_Object;
begin
    new(result);
    result^._workList:=nil;
    result^._nameList:=nil;
end;

procedure AFC_Config_Object__DST(const CFG:pAFC_Config_Object);
begin
    CFG^._nameList.FREE;
    CFG^._workList.FREE;
    Dispose(CFG);
end;

procedure _AFC_Config_Object__workList_Make(const CFG:pAFC_Config_Object);
var i:integer;
    s:string;
begin // все переводим в UpperCase
    with CFG^ do begin
        if (not Assigned(_workList))and(not _fold_ALL)and(_fold_LST)
        then _workList:=TStringList.Create;
        //---
        if Assigned(_workList) then begin
           _workList.Clear;
            if (not _fold_ALL)and(_fold_LST) then begin
                for i:=0 to _nameList.Count-1 do begin
                    s:=UpperCase(_nameList.Strings[i]);
                    if (s<>'')and(_workList.IndexOf(s)<0) then _workList.Add(s);
                end;
            end;
        end;
        //---
        if Assigned(_workList) then begin
            if _workList.Count=0 then begin
                FreeAndNil(_workList);
            end;
        end;
    end;
end;

procedure AFC_Config_Object__DEF(const CFG:pAFC_Config_Object);
begin
    with CFG^ do begin
       _lazExtON:=cIn0k_lazExt_AFN_defVAL_ExtnsnON;
       _fold_ALL:=cIn0k_lazExt_AFN_defVAL_fold_ALL;
       _fold_LST:=cIn0k_lazExt_AFN_defVAL_fold_LST;
       _fold_HFC:=cIn0k_lazExt_AFN_defVAL_fold_HFC;
       _nameList.Clear;
       _nameList.Add(cIn0k_lazExt_AFN_defVAL_lst_FOLD);
       _nameList.Add(cIn0k_lazExt_AFN_defVAL_lst_TODO);
    end;
   _AFC_Config_Object__workList_Make(CFG);
end;

//------------------------------------------------------------------------------

procedure AFC_Config_Object__nameList_LOAD(const CFG:pAFC_Config_Object; const names:tStrings);
var i:integer;
    s:string;
begin // исключаем пустое и дублирование
    with CFG^ do begin
       _nameList.Clear;
        for i:=0 to names.Count-1 do begin
            s:=trim(names.Strings[i]);
            if (s<>'')and(_nameList.IndexOf(s)<0) then _nameList.Add(s);
        end;
    end;
   _AFC_Config_Object__workList_Make(CFG);
end;

procedure AFC_Config_Object__nameList_SAVE(const CFG:pAFC_Config_Object; const names:tStrings);
begin
    names.clear;
    names.AddStrings(CFG^._nameList);
end;

end.

