unit in0k_lazExt_AFC;

{$mode objfpc}{$H+}

interface
uses Classes, sysutils, LCLProc,
 BaseIDEIntf, LazIDEIntf, SrcEditorIntf,
 LazConfigStorage,
 SynEdit, in0k_lazExt_AFC_synEdit;

const
 cIn0k_lazExt_AFC_Name='in0k_lazExt_AFC';

type

 tIn0k_lazExt_AFC=class
  strict private
   _lastProc:tIn0k_lazExt_AFC_synEdit; //< последний ОБРАБОТАННЫЙ
   _workList:tStrings;                 //< реально работающий список "Имен"
  protected //< ВСЯ СУТЬ этого "дополнения"
    procedure _workList_Make;
    function  _perform_AFC_getActiveEditor:tIn0k_lazExt_AFC_synEdit;
    procedure _perform_AFC;
  protected //< СОБЫТИЯ
    procedure _ideEvent_srcEditorActivate(Sender: TObject);
    procedure _ideEvent_closeIDE(Sender: TObject);
  protected //< и их РЕГИСТРАЦИЯ
    procedure _ideEvents_Register;
    procedure _ideEvents_unRegister;
  protected //< настройки
   _nameList:tStrings; //< список "Имен"
   _lazExtON:boolean;  //< мы вообще работаем
   _fold_ALL:boolean;  //< сворачивать ВСЕ
    procedure _nameList_set(const names:tStrings);
    procedure _nameList_get(const names:tStrings);
  protected
    procedure _settings_Load;
    procedure _settings_Save;
    procedure _settings_toDefault;
  public
    constructor Create;
    destructor DESTROY; override;
  public
    property  Extension_ON        :boolean read _lazExtON write _lazExtON;
    property  AutoFoldComments_ALL:boolean read _fold_ALL write _fold_ALL;
    procedure AutoFoldComments_NAMEs_get(const strings:TStrings);
    procedure AutoFoldComments_NAMEs_set(const strings:TStrings);
  public
    procedure SaveSettings;
    procedure SaveDefSettings;
  end;

procedure In0k_lazExt_AFC__CREATE;
function  In0k_lazExt_AFC:tIn0k_lazExt_AFC;

implementation

constructor tIn0k_lazExt_AFC.Create;
begin
   _lastProc:=nil;
   _nameList:=TStringList.Create;
   _workList:=TStringList.Create;
    //---
   _settings_Load;
    //---
   _ideEvents_register;
end;

destructor tIn0k_lazExt_AFC.DESTROY;
begin
    inherited;
   _nameList.FREE;
   _workList.FREE;
end;

//------------------------------------------------------------------------------

{%region --- события IDE Lazarus ---------------------------------- /fold}

procedure tIn0k_lazExt_AFC._ideEvent_closeIDE(Sender: TObject);
begin
    {*2> причины использования `_closeIDE` /fold
        не понятно по какому принципу необходимо отписываться от событий.
        но без этого Lazarus завершается с утечкой памяти или вообще падает.
    <*2}
   _ideEvents_unRegister;
end;

procedure tIn0k_lazExt_AFC._ideEvent_srcEditorActivate(Sender: TObject);
begin
    if _lazExtON then _perform_AFC;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const cIn0k_lazExt_AFNC_registerEvent=semEditorActivate;

procedure tIn0k_lazExt_AFC._ideEvents_register;
begin
    LazarusIDE.AddHandlerOnIDEClose(@_ideEvent_closeIDE);
    SourceEditorManagerIntf.RegisterChangeEvent(cIn0k_lazExt_AFNC_registerEvent, @_ideEvent_srcEditorActivate);
end;

procedure tIn0k_lazExt_AFC._ideEvents_unRegister;
begin
    LazarusIDE.RemoveHandlerOnIDEClose(@_ideEvent_closeIDE);
    SourceEditorManagerIntf.UnRegisterChangeEvent(cIn0k_lazExt_AFNC_registerEvent, @_ideEvent_srcEditorActivate);
end;

{%endregion}

{%region --- ВСЯ СУТь --------------------------------------------- /fold}

procedure tIn0k_lazExt_AFC._workList_Make;
var i:integer;
begin // все переводим в UpperCase
   _workList.Clear;
    if not _fold_ALL then begin
        for i:=0 to _nameList.Count-1 do begin
           _workList.Add(UpperCase(_nameList.Strings[i]));
        end;
    end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function tIn0k_lazExt_AFC._perform_AFC_getActiveEditor:tIn0k_lazExt_AFC_synEdit;
begin // вытягиваем текущий активный synEdit
    pointer(result):=SourceEditorManagerIntf.ActiveEditor;
    if Assigned(result) then begin
        result:=tIn0k_lazExt_AFC_synEdit(TCustomSynEdit(TSourceEditorInterface(pointer(result)).EditorControl));
    end;
end;

procedure tIn0k_lazExt_AFC._perform_AFC;
var tmpEdit:tIn0k_lazExt_AFC_synEdit;
begin
    tmpEdit:=_perform_AFC_getActiveEditor;
    if Assigned(tmpEdit) then begin
        {*1> причины использования `_lastProcessed` /fold
            механизм с `_lastProcessed` приходится использовать из-за того, что
            при переключение "Вкладок Редактора Исходного Кода" вызов данного
            события происходит аж 3(три) раза.
            Почему так происходит - повод для дальнейших разобирательств.
        <*1}
        if _lastProc<>tmpEdit then begin
            if not _fold_ALL
            then tmpEdit.foldComments_Name(_workList)
            else tmpEdit.foldComments_ALL;
           _lastProc:=tmpEdit;
        end;
    end;
end;

{%endregion}

{%region --- НАСТРОЙКИ -------------------------------------------- /fold}

const
   cIn0k_lazExt_AFNC_ExtnsnON='ExtnsnON';
   cIn0k_lazExt_AFNC_fold_ALL='fold_ALL';
   cIn0k_lazExt_AFNC_nameList='nameList';
   //----
   cIn0k_lazExt_AFNC_nameFOLD='/fold';
   cIn0k_lazExt_AFNC_nameTODO='todo';

//------------------------------------------------------------------------------

procedure tIn0k_lazExt_AFC._settings_Load;
var Config:TConfigStorage;
    tmpSTR:tStrings;
begin
    try tmpSTR:=TStringList.Create;
        Config:=GetIDEConfigStorage(cIn0k_lazExt_AFC_Name+'.xml',true);
        try if FileExists(Config.GetFilename) then begin
              _lazExtON:=Config.GetValue(cIn0k_lazExt_AFNC_ExtnsnON,true);
              _fold_ALL:=Config.GetValue(cIn0k_lazExt_AFNC_fold_ALL,false);
               Config.GetValue(cIn0k_lazExt_AFNC_nameList, tmpSTR);
              _nameList_set(tmpSTR);
            end
            else begin
              _settings_toDefault;
            end;
        finally
            Config.FREE;
            tmpSTR.FREE;
        end;
    except
      on E:Exception do begin
          DebugLn(['Reading '+cIn0k_lazExt_AFC_Name+'.xml failed: ',E.Message]);
      end;
    end
end;

procedure tIn0k_lazExt_AFC._settings_Save;
var Config:TConfigStorage;
begin
    try Config:=GetIDEConfigStorage(cIn0k_lazExt_AFC_Name+'.xml',false);
        try Config.SetValue(cIn0k_lazExt_AFNC_ExtnsnON,_lazExtON);
            Config.SetValue(cIn0k_lazExt_AFNC_fold_ALL,_fold_ALL);
            Config.SetValue(cIn0k_lazExt_AFNC_nameList,_nameList);
        finally
            Config.FREE;
        end;
    except
      on E:Exception do begin
          DebugLn(['Saving '+cIn0k_lazExt_AFC_Name+'.xml failed: ',E.Message]);
      end;
    end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tIn0k_lazExt_AFC._settings_toDefault;
begin
   _fold_ALL:=false;
   _nameList.Clear;
   _nameList.Add(cIn0k_lazExt_AFNC_nameFOLD);
   _nameList.Add(cIn0k_lazExt_AFNC_nameTODO);
   _workList_Make;
   _lazExtON:=TRUE;
end;

//------------------------------------------------------------------------------

procedure tIn0k_lazExt_AFC._nameList_set(const names:tStrings);
var i:integer;
    s:string;
begin // исключаем пустое и дублирование
   _nameList.Clear;
    for i:=0 to names.Count-1 do begin
        s:=trim(names.Strings[i]);
        if (s<>'')and(_nameList.IndexOf(s)<0) then _nameList.Add(s);
    end;
    //---
   _workList_Make;
end;

procedure tIn0k_lazExt_AFC._nameList_get(const names:tStrings);
begin
    names.clear;
    names.AddStrings(_nameList);
end;

{%endregion}

//------------------------------------------------------------------------------

procedure tIn0k_lazExt_AFC.AutoFoldComments_NAMEs_get(const strings:TStrings);
begin
   _nameList_get(strings);
end;

procedure tIn0k_lazExt_AFC.AutoFoldComments_NAMEs_set(const strings:TStrings);
begin
   _nameList_set(strings);
   _settings_Save;
end;

//------------------------------------------------------------------------------

procedure tIn0k_lazExt_AFC.SaveDefSettings;
begin
   _settings_toDefault;
   _settings_Save;
end;

procedure tIn0k_lazExt_AFC.SaveSettings;
begin
   _settings_Save;
end;

//==============================================================================
var _In0k_lazExt_AFNC_:tIn0k_lazExt_AFC;

function In0k_lazExt_AFC:tIn0k_lazExt_AFC;
begin
   result:=_In0k_lazExt_AFNC_;
end;

procedure In0k_lazExt_AFC__CREATE;
begin
   _In0k_lazExt_AFNC_:=tIn0k_lazExt_AFC.Create;
end;

initialization
_In0k_lazExt_AFNC_:=nil;
finalization
_In0k_lazExt_AFNC_.Free;
end.

