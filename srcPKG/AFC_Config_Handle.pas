unit AFC_Config_Handle;

{$mode objfpc}{$H+}

interface

uses  CbSFP_SubScriber, AFC_Config_Object, BaseIDEIntf, LazConfigStorage,
  Classes, SysUtils;

type

 tAFC_Config_Handle=class(tCbSFP_SubScriber_handle)
  public
    class function Identifier:string; override;
  public //< работа с объектом "КОНФИГУРАЦИЯ"
    function  ConfigOBJ_CRT:pointer;            override;
    procedure ConfigOBJ_DST(const Obj:pointer); override;
    procedure ConfigOBJ_DEF(const Obj:pointer); override;
  public //< работа с файлом
    function  ConfigOBJ_FileEXT:string; override;
    function  ConfigOBJ_Save(const Obj:pointer; const FileName:string):boolean; override;
    function  ConfigOBJ_Load(const Obj:pointer; const FileName:string):boolean; override;
  end;

procedure AFC_Config_SAVE(const Config:pAFC_Config_Object; const FileName:string);
procedure AFC_Config_LOAD(const Config:pAFC_Config_Object; const FileName:string);

implementation

{$region --- сохранение конфигурации в TConfigStorage ------------ /fold }

const //< названия узлов в "конфиге"
   cIn0k_lazExt_AFC_NN_ExtnsnON='ExtnsnON';
   cIn0k_lazExt_AFC_NN_fold_ALL='fold_ALL';
   cIn0k_lazExt_AFC_NN_fold_HFC='fold_HFC';
   cIn0k_lazExt_AFC_NN_fold_LST='fold_LST';
   cIn0k_lazExt_AFC_NN_nameLIST='nameLIST';

procedure _AFC_Config_SAVE_(const Config:pAFC_Config_Object; const ConfigStorage:TConfigStorage);
var tmpSTR:TStrings;
begin
    //--- сохраняем основные ФЛАГИ
    ConfigStorage.SetValue(cIn0k_lazExt_AFC_NN_ExtnsnON,Config^.lazExtON);
    ConfigStorage.SetValue(cIn0k_lazExt_AFC_NN_fold_ALL,Config^.fold_ALL);
    ConfigStorage.SetValue(cIn0k_lazExt_AFC_NN_fold_HFC,Config^.fold_HFC);
    ConfigStorage.SetValue(cIn0k_lazExt_AFC_NN_fold_LST,Config^.fold_LST);
    //--- сохраняем список-Имен
    {todo : чет кажется сложно делаю, наверно надо просче. ПОДУМАТЬ!}
    tmpSTR:=TStringList.Create;
    AFC_Config_Object__nameList_SAVE(Config,tmpSTR);
    ConfigStorage.SetValue(cIn0k_lazExt_AFC_NN_nameLIST,tmpSTR);
    tmpSTR.FREE;
end;

procedure _AFC_Config_LOAD_(const Config:pAFC_Config_Object; const ConfigStorage:TConfigStorage);
var tmpSTR:TStrings;
begin
    //--- грузим основные ФЛАГИ
    Config^.lazExtON:=ConfigStorage.GetValue(cIn0k_lazExt_AFC_NN_ExtnsnON,Config^.lazExtON);
    Config^.fold_ALL:=ConfigStorage.GetValue(cIn0k_lazExt_AFC_NN_fold_ALL,Config^.fold_ALL);
    Config^.fold_HFC:=ConfigStorage.GetValue(cIn0k_lazExt_AFC_NN_fold_HFC,Config^.fold_HFC);
    Config^.fold_LST:=ConfigStorage.GetValue(cIn0k_lazExt_AFC_NN_fold_LST,Config^.fold_LST);
    //--- загружаем список-Имен
    {todo : чет кажется сложно делаю, наверно надо просче. ПОДУМАТЬ!}
    tmpSTR:=TStringList.Create;
    AFC_Config_Object__nameList_SAVE(Config,tmpSTR);
    ConfigStorage.GetValue(cIn0k_lazExt_AFC_NN_nameLIST,tmpSTR);
    AFC_Config_Object__nameList_LOAD(Config,tmpSTR);
    tmpSTR.FREE;
end;

{$endregion}

{$region --- сохранение конфигурации в ФАЙЛ ---------------------- /fold }

function _ideConfigStorage_GET_(const FileName:string):tConfigStorage;
begin
    try
    result:=GetIDEConfigStorage(
        FileName,
        FileExists(FileName) //< если он есть то ЧИТАЕМ
            );

    except
      Raise Exception.Create('_ideConfigStorage_GET_');
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AFC_Config_SAVE(const Config:pAFC_Config_Object; const FileName:string);
var configStorage:tConfigStorage;
begin
    configStorage:=_ideConfigStorage_GET_(FileName);
    //---
   _AFC_Config_SAVE_(Config,configStorage);
    //---
    //configStorage.WriteToDisk;
    configStorage.FREE;
end;

procedure AFC_Config_LOAD(const Config:pAFC_Config_Object; const FileName:string);
var configStorage:tConfigStorage;
begin
    configStorage:=_ideConfigStorage_GET_(FileName);
    //---
   _AFC_Config_LOAD_(Config,configStorage);
    //---
    configStorage.FREE;
end;

{$endregion}

//------------------------------------------------------------------------------

class function tAFC_Config_Handle.Identifier:string;
begin
    result:='in0k_lazExt_AFC';
end;

//------------------------------------------------------------------------------

function tAFC_Config_Handle.ConfigOBJ_CRT:pointer;
begin
    result:=AFC_Config_Object__CRT;
end;

procedure tAFC_Config_Handle.ConfigOBJ_DST(const Obj:pointer);
begin
    AFC_Config_Object__DST(Obj);
end;

procedure tAFC_Config_Handle.ConfigOBJ_DEF(const Obj:pointer);
begin
    AFC_Config_Object__DEF(Obj);
end;

//------------------------------------------------------------------------------

const c_AFC_Config_Header_cnfgFileEXT='.xml';

function tAFC_Config_Handle.ConfigOBJ_FileEXT:string;
begin
    result:=c_AFC_Config_Header_cnfgFileEXT;
end;

//------------------------------------------------------------------------------

function tAFC_Config_Handle.ConfigOBJ_Save(const Obj:pointer; const FileName:string):boolean;
begin
    AFC_Config_SAVE(pAFC_Config_Object(Obj),FileName);
end;

function tAFC_Config_Handle.ConfigOBJ_Load(const Obj:pointer; const FileName:string):boolean;
begin
    AFC_Config_LOAD(pAFC_Config_Object(Obj),FileName);
end;

end.

