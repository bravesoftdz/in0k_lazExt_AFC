unit AFC_Config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

tAFC_Config_Object = class
 protected
  _workList:tStrings; //< реально работающий список "Имен" (upCASE)
   procedure _workList_Make;
 protected
  _nameList:tStrings; //< список "Имен"
  _lazExtON:boolean;  //< мы вообще работаем
  _fold_ALL:boolean;  //< сворачивать ВСЕ
  _fold_LST:boolean;  //< сворачивать ВСЕ
  _fold_HFC:boolean;  //< сворачивать Hint From Comment
   procedure _nameList_set(const names:tStrings);
   procedure _nameList_get(const names:tStrings);
 public
   constructor Create;
   destructor DESTROY; //override;
 public
   procedure toDefSTATE;
 public
   property  Extension_ON        :boolean read _lazExtON write _lazExtON;
   property  AutoFoldComments_ALL:boolean read _fold_ALL write _fold_ALL;
   property  AutoFoldComments_LST:boolean read _fold_LST write _fold_LST;
   property  AutoFoldComments_HFC:boolean read _fold_HFC write _fold_HFC;
   procedure AutoFoldComments_NAMEs_get(const strings:TStrings);
   procedure AutoFoldComments_NAMEs_set(const strings:TStrings);
 end;


implementation

const //< настройки по УМОЛЧАНИЮ
   cIn0k_lazExt_AFN_defVAL_ExtnsnON=TRUE;     //<
   cIn0k_lazExt_AFN_defVAL_fold_ALL=false;    //<
   cIn0k_lazExt_AFN_defVAL_fold_LST=true;     //<
   cIn0k_lazExt_AFN_defVAL_fold_HFC=true;     //<
   cIn0k_lazExt_AFN_defVAL_lst_FOLD='/fold';
   cIn0k_lazExt_AFN_defVAL_lst_TODO='todo';


constructor tAFC_Config_Object.Create;
begin
   _nameList:=TStringList.Create;
   _workList:=NIL;
end;

destructor tAFC_Config_Object.DESTROY; //override;
begin
   _nameList.FREE;
   _workList.FREE;
end;

//------------------------------------------------------------------------------

procedure tAFC_Config_Object.toDefSTATE;
begin
   _lazExtON:=cIn0k_lazExt_AFN_defVAL_ExtnsnON;
   _fold_ALL:=cIn0k_lazExt_AFN_defVAL_fold_ALL;
   _fold_LST:=cIn0k_lazExt_AFN_defVAL_fold_LST;
   _fold_HFC:=cIn0k_lazExt_AFN_defVAL_fold_HFC;
   _nameList.Clear;
   _nameList.Add(cIn0k_lazExt_AFN_defVAL_lst_FOLD);
   _nameList.Add(cIn0k_lazExt_AFN_defVAL_lst_TODO);
   _workList_Make;
end;

//------------------------------------------------------------------------------

procedure tAFC_Config_Object._workList_Make;
var i:integer;
    s:string;
begin // все переводим в UpperCase
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

//------------------------------------------------------------------------------

procedure tAFC_Config_Object._nameList_set(const names:tStrings);
var i:integer;
    s:string;
begin // исключаем пустое и дублирование
   _nameList.Clear;
    for i:=0 to names.Count-1 do begin
        s:=trim(names.Strings[i]);
        if (s<>'')and(_nameList.IndexOf(s)<0) then _nameList.Add(s);
    end;
   _workList_Make;
end;

procedure tAFC_Config_Object._nameList_get(const names:tStrings);
begin
    names.clear;
    names.AddStrings(_nameList);
end;

//------------------------------------------------------------------------------

procedure tAFC_Config_Object.AutoFoldComments_NAMEs_get(const strings:TStrings);
begin
   _nameList_get(strings);
end;

procedure tAFC_Config_Object.AutoFoldComments_NAMEs_set(const strings:TStrings);
begin
   _nameList_set(strings);
end;


end.

