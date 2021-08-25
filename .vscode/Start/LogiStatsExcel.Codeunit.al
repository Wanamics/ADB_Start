Codeunit 59900 "wan LogiStats Excel"
{
    trigger OnRun()
    begin
        ExcelBuffer.DeleteAll();
        Import();
        ExcelBuffer.SetRange("Row No.");
        ExcelBuffer.DeleteAll();
        Export(Rec);
    end;

    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer;
        SheetName: TextConst ENU = 'Data';
        Rec: Record "wan LogiStats Buffer";

    procedure Import()
    var
        ImportFromExcelTitle: TextConst ENU = 'Import Excel File', FRA = 'Importer fichier Excel';
        ExcelFileCaption: TextConst ENU = 'Excel Files (*.xlsx)', FRA = 'Fichiers Excel (*.xlsx)';
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        IStream: InStream;
        FileName: Text;
    begin
        if UploadIntoStream('', '', '', FileName, IStream) then begin
            ExcelBuffer.LOCKTABLE;
            ExcelBuffer.OpenBookStream(IStream, SheetName);
            ExcelBuffer.ReadSheet();
            AnalyzeData();
            ExcelBuffer.DeleteAll();
        end;
    end;

    local procedure AnalyzeData()
    var
        lRowNo: Integer;
        lNext: Integer;
        lCount: Integer;
        lProgress: Integer;
        lDialog: Dialog;
        ltAnalyzing: TextConst ENU = 'Analyzing Data...\\', FRA = 'Analyse des données';
    begin
        lDialog.Open(ltAnalyzing + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        lDialog.Update(1, 0);
        ExcelBuffer.SetFilter("Row No.", '>1'); // Skip Title
        lCount := ExcelBuffer.Count;
        if ExcelBuffer.FindSet then
            repeat
                Rec.Init();
                lRowNo := ExcelBuffer."Row No.";
                repeat
                    lProgress += 1;
                    ImportCell(Rec, ExcelBuffer."Column No.", ExcelBuffer."Cell Value as Text");
                    lNext := ExcelBuffer.Next;
                until (lNext = 0) or (ExcelBuffer."Row No." <> lRowNo);
                lDialog.Update(1, Round(lProgress / lCount * 10000, 1));
            until lNext = 0;
    end;

    local procedure ToDecimal(pText: Text) ReturnValue: Decimal
    begin
        Evaluate(ReturnValue, pText);
    end;

    local procedure ToDate(pText: Text) ReturnValue: Date
    begin
        Evaluate(ReturnValue, pText);
    end;

    procedure Export(var pRec: Record "wan LogiStats Buffer")
    var
        tConfirm: TextConst ENU = 'Do-you want to create an Excel book for %1 %2(s)?', FRA = 'Voulez-vous créer un classeur Excel pour %1 %2(s) ?';
        ProgressDialog: Codeunit "Excel Buffer Dialog Management";
    begin
        Rec.Copy(pRec);
        if not Confirm(tConfirm, true, Rec.Count, Rec.TableCaption) then
            exit;

        ProgressDialog.Open('');
        RowNo := 1;
        ColumnNo := 1;
        ExportTitles(pRec);
        if Rec.FindSet then
            repeat
                ProgressDialog.SetProgress(RowNo);
                RowNo += 1;
                ColumnNo := 1;
                ExportLine(Rec);
            until Rec.Next = 0;
        ProgressDialog.Close;

        ExcelBuffer.CreateNewBook(SheetName);
        ExcelBuffer.WriteSheet(pRec.TableCaption, CompanyName, UserId);
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename(SafeFileName(pRec));
        ExcelBuffer.OpenExcel;
    end;

    local procedure SafeFileName(pRec: Record "wan LogiStats Buffer"): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        exit(FileManagement.GetSafeFileName(pRec.TableCaption + ' - ' + CompanyName));
    end;

    local procedure EnterCell(pRowNo: Integer; var pColumnNo: Integer; pCellValue: Text; pBold: Boolean; pUnderLine: Boolean; pNumberFormat: Text; pCellType: Option)
    begin
        ExcelBuffer.Init;
        ExcelBuffer.Validate("Row No.", pRowNo);
        ExcelBuffer.Validate("Column No.", pColumnNo);
        ExcelBuffer."Cell Value as Text" := pCellValue;
        ExcelBuffer.Formula := '';
        ExcelBuffer.Bold := pBold;
        ExcelBuffer.Underline := pUnderLine;
        ExcelBuffer.NumberFormat := pNumberFormat;
        ExcelBuffer."Cell Type" := pCellType;
        ExcelBuffer.Insert;
        pColumnNo += 1;
    end;

    local procedure ExportTitles(pRec: Record "wan LogiStats Buffer")
    begin
        EnterCell(RowNo, ColumnNo, pRec.FieldCaption("Customer No."), true, false, '', ExcelBuffer."cell type"::Text); // 1
        EnterCell(RowNo, ColumnNo, pRec.FieldCaption("Posting Date"), true, false, '', ExcelBuffer."cell type"::Text); // 2
        EnterCell(RowNo, ColumnNo, pRec.FieldCaption("Order Type"), true, false, '', ExcelBuffer."cell type"::Text); // 3
        EnterCell(RowNo, ColumnNo, pRec.FieldCaption(Sales), true, false, '', ExcelBuffer."cell type"::Text); // 4
        EnterCell(RowNo, ColumnNo, pRec.FieldCaption("Profit"), true, false, '', ExcelBuffer."cell type"::Text); // 5
    end;

    local procedure ExportLine(pRec: Record "wan LogiStats Buffer")
    begin
        EnterCell(RowNo, ColumnNo, pRec."Customer No.", false, false, '', ExcelBuffer."cell type"::Text); // 1
        EnterCell(RowNo, ColumnNo, format(pRec."Posting Date"), false, false, '', ExcelBuffer."cell type"::Date); // 2
        EnterCell(RowNo, ColumnNo, pRec."Order Type", false, false, '', ExcelBuffer."cell type"::Text); // 3
        EnterCell(RowNo, ColumnNo, format(pRec.Sales), false, false, '', ExcelBuffer."cell type"::Number); // 4
        EnterCell(RowNo, ColumnNo, format(pRec."Profit"), false, false, '', ExcelBuffer."cell type"::Number); // 5
    end;

    local procedure ImportCell(var pRec: Record "wan LogiStats Buffer"; pColumnNo: Integer; pText: Text)
    begin
        case pColumnNo of
            3:
                pRec.Validate("Customer No.", copystr(pText, 1, 6));
            6:
                case pText of
                    'F':
                        pRec.Validate("Order Type", 'ETB');
                    'G':
                        pRec.Validate("Order Type", 'ETB');
                    'I':
                        pRec.Validate("Order Type", 'ADB');
                    'O':
                        pRec.Validate("Order Type", 'ADB');
                end;
            10 .. 21:
                begin
                    pRec."Posting Date" := calcdate(format(pColumnNo - 10) + 'M', 20200101D);
                    if ExcelBuffer."Row No." mod 2 = 0 then begin
                        pRec.Sales := ToDecimal(pText);
                        pRec.Insert();
                    end else begin
                        pRec.Find('=');
                        pRec.Profit := pRec.Sales * ToDecimal(pText) / 100;
                        Rec.Modify();
                    end;
                end;
        end;
    end;

}

