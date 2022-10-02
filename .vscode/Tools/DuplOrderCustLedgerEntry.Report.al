report 59919 "_Dupl. Order CustLedgerEntry"
{
    ApplicationArea = All;
    Caption = 'Dupl. PrestaShop Order CustLedgerEntry ';
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            RequestFilterFields = "Customer No.";

            DataItemTableView =
                sorting("Customer No.", "External Document No.", Description)
                where("Document Type" = const(Invoice), "External Document No." = filter(<> ''));
            column(customerNumber; CustLedgerEntry."Customer No.") { }
            column(externalDocumentNo; CustLedgerEntry."External Document No.") { }
            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do-you want to find duplicate PrestaShop Order from %1 %2?';
            begin
                if not Confirm(tConfirm, false, Count, TableCaption()) then
                    CurrReport.Quit()
                else begin
                    ExcelBuffer.AddColumn(FieldCaption("Customer No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(FieldCaption("External Document No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
                //SetCurrentKey("Customer No.", "External Document No.", Description);
                //SetLoadFields("Customer No.", "External Document No.", Description);
            end;

            trigger OnAfterGetRecord()
            begin
                if ("External Document No." = xCustLedgerEntry."External Document No.") and
                    (GetOrderNo(Description) <> GetOrderNo(xCustLedgerEntry.Description)) then begin
                    ExcelBuffer.NewRow();
                    ExcelBuffer.AddColumn("Customer No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn("External Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;

                xCustLedgerEntry := CustLedgerEntry;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    var
        xCustLedgerEntry: Record "Cust. Ledger Entry";
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

    local procedure GetOrderNo(pDescription: Text): Text
    var
        Pos: Integer;
    begin
        Pos := pDescription.IndexOf(' CV');
        if Pos <> 0 then
            exit(pDescription.Substring(Pos + 1, 7))
        else
            exit(pDescription);
    end;
}
