unit AFC_Config_Object;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils;

type

 rAFC_Config_Object=record
    workList:tStrings; //< реально работающий список "Имен" (upCASE)
    nameList:tStrings; //< список "Имен"
    lazExtON:boolean;  //< мы вообще работаем
    fold_ALL:boolean;  //< сворачивать ВСЕ
    fold_LST:boolean;  //< сворачивать использовать списки
    fold_HFC:boolean;  //< сворачивать Hint From Comment
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
    result^.workList:=nil;
    result^.nameList:=TStringList.Create;
end;

procedure AFC_Config_Object__DST(const CFG:pAFC_Config_Object);
begin
    CFG^.nameList.FREE;
    CFG^.workList.FREE;
    Dispose(CFG);
end;

procedure _AFC_Config_Object__workList_Make(const CFG:pAFC_Config_Object);
var i:integer;
    s:string;
begin // все переводим в UpperCase
    with CFG^ do begin
        if (not Assigned(workList))and(not fold_ALL)and(fold_LST)
        then workList:=TStringList.Create;
        //---
        if Assigned(workList) then begin
           workList.Clear;
            if (not fold_ALL)and(fold_LST) then begin
                for i:=0 to nameList.Count-1 do begin
                    s:=UpperCase(nameList.Strings[i]);
                    if (s<>'')and(workList.IndexOf(s)<0) then workList.Add(s);
                end;
            end;
        end;
        //---
        if Assigned(workList) then begin
            if workList.Count=0 then begin
                FreeAndNil(workList);
            end;
        end;
    end;
end;

procedure AFC_Config_Object__DEF(const CFG:pAFC_Config_Object);
begin
    with CFG^ do begin
       lazExtON:=cIn0k_lazExt_AFN_defVAL_ExtnsnON;
       fold_ALL:=cIn0k_lazExt_AFN_defVAL_fold_ALL;
       fold_LST:=cIn0k_lazExt_AFN_defVAL_fold_LST;
       fold_HFC:=cIn0k_lazExt_AFN_defVAL_fold_HFC;
       nameList.Clear;
       nameList.Add(cIn0k_lazExt_AFN_defVAL_lst_FOLD);
       nameList.Add(cIn0k_lazExt_AFN_defVAL_lst_TODO);
    end;
   _AFC_Config_Object__workList_Make(CFG);
end;

//------------------------------------------------------------------------------

procedure AFC_Config_Object__nameList_LOAD(const CFG:pAFC_Config_Object; const names:tStrings);
var i:integer;
    s:string;
begin // исключаем пустое и дублирование
    with CFG^ do begin
        nameList.Clear;
        for i:=0 to names.Count-1 do begin
            s:=trim(names.Strings[i]);
            if (s<>'')and(nameList.IndexOf(s)<0) then nameList.Add(s);
        end;
    end;
   _AFC_Config_Object__workList_Make(CFG);
end;

procedure AFC_Config_Object__nameList_SAVE(const CFG:pAFC_Config_Object; const names:tStrings);
begin
    names.clear;
    names.AddStrings(CFG^.nameList);
end;

end.

