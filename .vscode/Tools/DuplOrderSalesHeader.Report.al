report 59920 "_Dupl. Order SalesHeader"
{
    ApplicationArea = All;
    Caption = 'Dupl. PrestaShop Order SalesHeader ';
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            RequestFilterFields = "Sell-to Customer No.";

            DataItemTableView =
                sorting("Sell-to Customer No.", "External Document No.")
                where("Document Type" = const(Order), "External Document No." = filter(<> ''));
            column(customerNumber; "Sell-to Customer No.") { }
            column(externalDocumentNo; "External Document No.") { }
            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do-you want to find duplicate PrestaShop Order from %1 %2?';
            begin
                if not Confirm(tConfirm, false, Count, TableCaption()) then
                    CurrReport.Quit()
                else begin
                    ExcelBuffer.NewRow();
                    ExcelBuffer.AddColumn(fieldcaption("Sell-to Customer No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(fieldcaption("External Document No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                if ("External Document No." = xSalesHeader."External Document No.") and
                    (GetOrderNo("No.") <> GetOrderNo(xSalesHeader."No.")) then begin
                    ExcelBuffer.NewRow();
                    ExcelBuffer.AddColumn("Sell-to Customer No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn("External Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;

                xSalesHeader := SalesHeader;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    var
        xSalesHeader: Record "Sales Header";
        ExcelBuffer: Record "Excel Buffer" temporary;
        SheetName: TextConst ENU = 'Data';

    trigger OnPostReport()
    begin
        ExcelBuffer.CreateNewBook(SheetName);
        ExcelBuffer.WriteSheet(CurrReport.ObjectId(false), CompanyName, UserId);
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename(CurrReport.ObjectId(true));
        ExcelBuffer.OpenExcel;
    end;

    local procedure GetOrderNo(pNo: Text): Text
    var
        Pos: Integer;
    begin
        Pos := pNo.IndexOf('.');
        if Pos <> 0 then
            exit(pNo.Substring(1, Pos - 1))
        else
            exit(pNo);
    end;
}
