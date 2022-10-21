Codeunit 59901 "wan LogiStats Import"
{
    Permissions =
        tabledata "Sales Invoice Header" = i,
        tabledata "Sales Invoice Line" = i;

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
                lRowNo := ExcelBuffer."Row No.";
                repeat
                    lProgress += 1;
                    ImportCell(Rec, ExcelBuffer."Column No.", ExcelBuffer."Cell Value as Text");
                    lNext := ExcelBuffer.Next;
                until (lNext = 0) or (ExcelBuffer."Row No." <> lRowNo);
                lDialog.Update(1, Round(lProgress / lCount * 10000, 1));
                CreatePostedInvoice(Rec)
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


    local procedure ImportCell(var pRec: Record "wan LogiStats Buffer"; pColumnNo: Integer; pText: Text)
    begin
        case pColumnNo of
            1:
                pRec.Validate("Customer No.", pText);
            2:
                pRec."Posting Date" := ToDate(pText);
            3:
                pRec."Order Type" := pText;
            4:
                pRec.Sales := ToDecimal(pText);
            5:
                pRec.Profit := ToDecimal(pText);
        end;
    end;

    local procedure CreatePostedInvoice(pRec: Record "wan LogiStats Buffer")
    var
        SIH: Record "Sales Invoice Header";
        SIL: Record "Sales Invoice Line";
    begin
        SIH."No." := 'FV' + format(Date2DMY(prec."Posting Date", 3), 2) + format(Date2DMY(pRec."Posting Date", 2), 2) + prec."Customer No.";
        SIH."No." := ConvertStr(SIH."No.", ' ', '0');
        SIH."Bill-to Customer No." := pRec."Customer No.";
        SIH."Sell-to Customer No." := pRec."Customer No.";
        SIH."Posting Date" := pRec."Posting Date";
        SIH."Shipment Method Code" := pRec."Order Type";
        SIH.Insert();
        SIL."Document No." := SIH."No.";
        SIL."Bill-to Customer No." := SIH."Bill-to Customer No.";
        SIL."Sell-to Customer No." := SIH."Sell-to Customer No.";
        SIL."Posting Date" := SIH."Posting Date";
        SIL."Line No." := 10000;
        SIL.Type := SIL.Type::Item;
        SIL."Quantity (Base)" := 1;
        SIL.Amount := pRec.Sales;
        SIL."Unit Cost (LCY)" := pRec.Sales - pRec.Profit;
        SIL.Insert();
    end;

}

