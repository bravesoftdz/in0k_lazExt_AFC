unit AFC_Config_Header;

{$mode objfpc}{$H+}

interface

uses  CbSFP_SubScriber, AFC_Config,
  Classes, SysUtils;

type

 tAFC_Config_Header=class(tCbSFP_SubScriber_handle)
  public
    // идентификатор подписчика (уникальное среди используемых)
    class function Identifier:string; override;
  public //< работа с объектом "КОНФИГУРАЦИЯ"
    // СОЗДАТЬ объект
    function  ConfigOBJ_CRT:pointer;            override;
    // УНИЧТОЖить объект
    procedure ConfigOBJ_DST(const Obj:pointer); override;
    // установить ПЕРВИЧНые (согласованные и безопасные) значения
    procedure ConfigOBJ_DEF(const Obj:pointer); override;
  public //< работа с файлом
    function  ConfigOBJ_FileEXT:string; override;
    function  ConfigOBJ_Save(const Obj:pointer; const FileName:string; const Used:boolean):boolean; override;
    function  ConfigOBJ_Load(const Obj:pointer; const FileName:string; var   Used:boolean):boolean; override;
  end;

implementation

class function tAFC_Config_Header.Identifier:string;
begin
    result:='in0k_lazExt_AFC';
end;

//------------------------------------------------------------------------------

function tAFC_Config_Header.ConfigOBJ_CRT:pointer;
begin
    result:=AFC_Config_Object__CRT;
end;

procedure tAFC_Config_Header.ConfigOBJ_DST(const Obj:pointer);
begin
    AFC_Config_Object__DST(Obj);
end;

procedure tAFC_Config_Header.ConfigOBJ_DEF(const Obj:pointer);
begin
    AFC_Config_Object__DEF(Obj);
end;

//------------------------------------------------------------------------------

const c_AFC_Config_Header_cnfgFileEXT='.xml';

function tAFC_Config_Header.ConfigOBJ_FileEXT:string;
begin
    result:=c_AFC_Config_Header_cnfgFileEXT;
end;

function tAFC_Config_Header.ConfigOBJ_Save(const Obj:tCbSFP_SubScriber_cnfOBJ; const FileName:string; const Used:boolean):boolean;
begin

end;

function tAFC_Config_Header.ConfigOBJ_Load(const Obj:tCbSFP_SubScriber_cnfOBJ; const FileName:string; var   Used:boolean):boolean;
begin

end;

//------------------------------------------------------------------------------

const //< названия узлов в "конфиге"
   cIn0k_lazExt_AFN_ExtnsnON='ExtnsnON';
   cIn0k_lazExt_AFN_fold_ALL='fold_ALL';
   cIn0k_lazExt_AFN_fold_HFC='fold_HFC';
   cIn0k_lazExt_AFN_fold_LST='fold_LST';
   cIn0k_lazExt_AFN_nameLIST='nameLIST';
{
procedure tIn0k_lazExt_AFC._settings_Load;
var Config:TConfigStorage;
    tmpSTR:TStrings;
begin
    try tmpSTR:=TStringList.Create;
        Config:=GetIDEConfigStorage(cIn0k_lazExt_AFC_Name+'.xml',true);
        try if FileExists(Config.GetFilename) then begin
              _lazExtON:=Config.GetValue(cIn0k_lazExt_AFN_ExtnsnON,false);
              _fold_ALL:=Config.GetValue(cIn0k_lazExt_AFN_fold_ALL,false);
              _fold_LST:=Config.GetValue(cIn0k_lazExt_AFN_fold_LST,false);
              _fold_HFC:=Config.GetValue(cIn0k_lazExt_AFN_fold_HFC,false);
               Config.GetValue(cIn0k_lazExt_AFN_nameLIST, tmpSTR);
              _nameList_set(tmpSTR);
            end
            else begin
              _settings_toDefault;
              _settings_Save;
            end;
        finally
            Config.FREE;
            tmpSTR.FREE;
        end;
    except
      {$ifOpt D+}
      on E:Exception do begin
          // вообще фиг знает что тут делать
          // DebugLn(['Reading '+cIn0k_lazExt_AFC_Name+'.xml failed: ',E.Message]);
      end;
      {$endIf}
    end
end;

procedure tIn0k_lazExt_AFC._settings_Save;
var Config:TConfigStorage;
begin
    try Config:=GetIDEConfigStorage(cIn0k_lazExt_AFC_Name+'.xml',false);
        try Config.SetValue(cIn0k_lazExt_AFN_ExtnsnON,_lazExtON);
            Config.SetValue(cIn0k_lazExt_AFN_fold_ALL,_fold_ALL);
            Config.SetValue(cIn0k_lazExt_AFN_fold_LST,_fold_LST);
            Config.SetValue(cIn0k_lazExt_AFN_fold_HFC,_fold_HFC);
            Config.SetValue(cIn0k_lazExt_AFN_nameLIST,_nameList);
        finally
            Config.FREE;
        end;
    except
      {$ifOpt D+}
      on E:Exception do begin
          // вообще фиг знает что тут делать
          // DebugLn(['Saving '+cIn0k_lazExt_AFC_Name+'.xml failed: ',E.Message]);
      end;
      {$endIf}
    end
end;
}


end.

