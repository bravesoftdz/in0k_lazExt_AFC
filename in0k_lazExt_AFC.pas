unit in0k_lazExt_AFC;
//----------------------------------------------------------------------------//
//   _____ _____ _____                                                        \\
//  |  _  |   __|     | auto                                                  //
//  |     |   __|   --| fold                                                  \\
//  |__|__|__|  |_____| comment                                               //
//                                                                            \\
//----------------------------------------------------------------------------//

{$mode objfpc}{$H+}

interface

uses {$ifOpt D+} in0k_lazExt_AFC_wndDBG, {$endIf}
    Classes, sysutils,
    LazConfigStorage,
    BaseIDEIntf, LazIDEIntf, SrcEditorIntf,
    CodeCache, SynEdit,
    in0k_lazExt_AFC_synEdit;

const
 cIn0k_lazExt_AFC_Name='in0k_lazExt_AFC';

type

 tIn0k_lazExt_AFC=class
  strict private
   _lastProc:tIn0k_lazExt_AFC_synEdit; //< последний ОБРАБОТАННЫЙ
   _workList:tStrings;                 //< реально работающий список "Имен" (upCASE)
    procedure _workList_Make;
  protected //< ВСЯ СУТЬ этого "дополнения"
    function  _perform_AFC_getActiveEditor(out CodeBuffer:TCodeBuffer):tIn0k_lazExt_AFC_synEdit;
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
   _fold_LST:boolean;  //< сворачивать ВСЕ
   _fold_HFC:boolean;  //< сворачивать Hint From Comment
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
    property  AutoFoldComments_LST:boolean read _fold_LST write _fold_LST;
    property  AutoFoldComments_HFC:boolean read _fold_HFC write _fold_HFC;
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
   _workList:=NIL;
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
    {*3> рабочее Событие. /fold
        При АКТИВАЦИИ вкладки редактора исходного кода выполняем "ДОБАВКУ"
    <*3}
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

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function tIn0k_lazExt_AFC._perform_AFC_getActiveEditor(out CodeBuffer:TCodeBuffer):tIn0k_lazExt_AFC_synEdit;
begin // вытягиваем текущий активный synEdit
    CodeBuffer     :=nil;
    pointer(result):=SourceEditorManagerIntf.ActiveEditor;
    if Assigned(result) then begin
        {$ifOpt D+}
       _dbgLOG_('getActiveEditor found:'+TSourceEditorInterface(pointer(result)).FileName);
        {$endIf}
        CodeBuffer:=TCodeBuffer(TSourceEditorInterface(pointer(result)).CodeToolsBuffer);
        if assigned(CodeBuffer)
        then result:=tIn0k_lazExt_AFC_synEdit(TCustomSynEdit(TSourceEditorInterface(pointer(result)).EditorControl))
        else begin
            result:=nil;
            {$ifOpt D+}
           _dbgLOG_('CodeBuffer is NULL');
            {$endIf}
        end
    end
    {$ifOpt D+}
    else begin
        _dbgLOG_('SourceEditorManagerIntf.ActiveEditor is NULL');
    end
    {$endIf}
end;

procedure tIn0k_lazExt_AFC._perform_AFC;
var tmpEdit:tIn0k_lazExt_AFC_synEdit;
    CodeBuf:TCodeBuffer;
begin
    tmpEdit:=_perform_AFC_getActiveEditor(CodeBuf);
    if Assigned(tmpEdit) and Assigned(CodeBuf) then begin
        {*1> причины использования `_lastProcessed` /fold
            механизм с `_lastProcessed` приходится использовать из-за того, что
            при переключение "Вкладок Редактора Исходного Кода" вызов данного
            события происходит аж 3(три) раза.
            Почему так происходит - повод для дальнейших разобирательств.
        <*1}
        if _lastProc<>tmpEdit then begin
            {$ifOpt D+}
           _dbgLOG_(' ==== START for file :'+CodeBuf.Filename);
            {$endIf}
            if not _fold_ALL then begin
                if not _fold_HFC

                //then CodeBuf:=nil; //< использовать НЕ будем
                then tmpEdit.foldComments_Name(_workList,nil)
                else tmpEdit.foldComments_Name(_workList,CodeBuf)
            end
            else tmpEdit.foldComments_ALL;
            {$ifOpt D+}
           _dbgLOG_(' ====  END  =========:');
            {$endIf}
           _lastProc:=tmpEdit;
        end;
    end;
end;

{%endregion}

{%region --- НАСТРОЙКИ -------------------------------------------- /fold}

const //< настройки по УМОЛЧАНИЮ
   cIn0k_lazExt_AFN_defVAL_ExtnsnON=TRUE;     //<
   cIn0k_lazExt_AFN_defVAL_fold_ALL=false;    //<
   cIn0k_lazExt_AFN_defVAL_fold_LST=true;     //<
   cIn0k_lazExt_AFN_defVAL_fold_HFC=true;     //<
   cIn0k_lazExt_AFN_defVAL_lst_FOLD='/fold';
   cIn0k_lazExt_AFN_defVAL_lst_TODO='todo';

procedure tIn0k_lazExt_AFC._settings_toDefault;
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

const //< названия узлов в "конфиге"
   cIn0k_lazExt_AFN_ExtnsnON='ExtnsnON';
   cIn0k_lazExt_AFN_fold_ALL='fold_ALL';
   cIn0k_lazExt_AFN_fold_HFC='fold_HFC';
   cIn0k_lazExt_AFN_fold_LST='fold_LST';
   cIn0k_lazExt_AFN_nameLIST='nameLIST';

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

