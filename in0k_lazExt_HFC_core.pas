unit in0k_lazExt_HFC_core;

{$mode objfpc}{$H+}

interface

uses {$ifOpt D+}LCLProc,{$endif}
    BasicCodeTools, CodeCache, CodeToolManager,
    SynEditHighlighterFoldBase;

function in0k_lazExt_HFC__getOwnerAtomINDEX(const Code:TCodeBuffer; const SNFNI:PSynFoldNodeInfo):integer;

implementation

const chintDoc_CORE_CommentBelongsToPrior_SMB   ='<';
const chintDoc_CORE_CommentBelongsToPrior_SMBlen=length(chintDoc_CORE_CommentBelongsToPrior_SMB);

function hintDoc_CORE_CommentBelongsToPrior(const firstLineCommentTEXT:string; const Column,ColumnLen:integer):boolean;
{$ifOpt D+}
var s:string;
{$endif}
begin
    if length(firstLineCommentTEXT)>Column+ColumnLen+chintDoc_CORE_CommentBelongsToPrior_SMBlen
    then begin
        {$ifOpt D+}
            S:=copy(firstLineCommentTEXT,Column+ColumnLen,chintDoc_CORE_CommentBelongsToPrior_SMBlen);
            DbgOut('hintDoc_CORE_CommentBelongsToPrior_SMB->'+S+'<-');
        {$endif}
        result:=chintDoc_CORE_CommentBelongsToPrior_SMB = copy(firstLineCommentTEXT,Column+ColumnLen,chintDoc_CORE_CommentBelongsToPrior_SMBlen)
    end
    else result:=false
end;

//---
const chintDoc_CORE_err_SourceBulidTREE=-100;
      chintDoc_CORE_err_ToolObtain     =-101;
//---

function hintDoc_CORE_001_findPrior(const Code:TCodeBuffer; const LineIndex,Column,ColumnLen:integer):integer;
var Tool:TCodeTool;
    CodeXYPosition:TCodeXYPosition;
    ALineStart, ALineEnd, AFirstAtomStart, ALastAtomEnd: integer;
    CleanCursorTMP:integer;
begin
    result:=-1;
    {$ifOpt D+}DbgOut('hintDoc_CORE_001_Prior');{$endif}
    CodeToolBoss.Explore(Code,Tool,false,false);
    if not Assigned(Tool) then result:=chintDoc_CORE_err_ToolObtain
    else begin
        CodeXYPosition.Code:=Code;
        CodeXYPosition.X   :=Column;//+ColumnLen+1;
        CodeXYPosition.Y   :=LineIndex+1;

        try    Tool.BuildTreeAndGetCleanPos(CodeXYPosition,result);
        except result:=chintDoc_CORE_err_SourceBulidTREE end;

        if result>0 then begin
            repeat
                CleanCursorTMP:=result;
                result:=Tool.FindLineEndOrCodeInFrontOfPosition(result,false,true);
                Tool.GetLineInfo(result, ALineStart, ALineEnd, AFirstAtomStart, ALastAtomEnd);
                if ALineStart=ALineEnd then begin
                    result:=-1; //< наткнулись на ПУСТУЮ строку
                    break;
                end;
            until (result=ALastAtomEnd)    //< что-то ВАЖНОЕ
                or(CleanCursorTMP=result); //< стоим на оджном месте
        end;
    end;
end;

function hintDoc_CORE_001_findAfter(const Code:TCodeBuffer; const LineIndex,Column,ColumnLen:integer):integer;
var Tool:TCodeTool;
    CodeXYPosition:TCodeXYPosition;
    ALineStart, ALineEnd, AFirstAtomStart, ALastAtomEnd: integer;
    CleanCursorTMP:integer;
begin
    result:=-1;
    {$ifOpt D+}DbgOut('hintDoc_CORE_001_After');{$endif}
    CodeToolBoss.Explore(Code,Tool,false,false);
    if not Assigned(Tool) then result:=chintDoc_CORE_err_ToolObtain
    else begin
        CodeXYPosition.Code:=Code;
        CodeXYPosition.X   :=Column;//+ColumnLen+1;
        CodeXYPosition.Y   :=LineIndex+1;

        try    Tool.BuildTreeAndGetCleanPos(CodeXYPosition,result);
        except result:=chintDoc_CORE_err_SourceBulidTREE end;

        if result>0 then begin
            repeat
                CleanCursorTMP:=result;
                result:=Tool.FindLineEndOrCodeAfterPosition(result,false,true);
                Tool.GetLineInfo(result, ALineStart, ALineEnd, AFirstAtomStart, ALastAtomEnd);
                if ALineStart=ALineEnd then begin
                    result:=-1; //< наткнулись на ПУСТУЮ строку
                    break;
                end;
            until (result=AFirstAtomStart) //< что-то ВАЖНОЕ
                or(CleanCursorTMP=result); //< стоим на оджном месте
        end;
    end;
end;

function hintDoc_CORE_01(const Code:TCodeBuffer; const LineIndex,Column,ColumnLen:integer):integer;
begin
    if hintDoc_CORE_CommentBelongsToPrior(code.GetLine(LineIndex), Column,ColumnLen)
    then result:=hintDoc_CORE_001_findPrior(Code,LineIndex,Column,ColumnLen)
    else result:=hintDoc_CORE_001_findAfter(Code,LineIndex,Column,ColumnLen);
end;

function in0k_lazExt_HFC__getOwnerAtomINDEX(const Code:TCodeBuffer; const SNFNI:PSynFoldNodeInfo):integer;
begin
    result:=hintDoc_CORE_01(Code,SNFNI^.LineIndex,SNFNI^.LogXEnd+1,SNFNI^.LogXEnd - SNFNI^.LogXStart);
end;

end.

