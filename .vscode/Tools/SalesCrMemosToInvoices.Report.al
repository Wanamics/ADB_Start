//#Statistiques
report 59910 "wan Sales Cr.Memos to Invoices"
{
    ApplicationArea = All;
    CaptionML = ENU = 'Duplicate Sales Cr.Memos to Invoices', FRA = 'Dupliquer avoirs vente en factures';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata 112 = i, tabledata 113 = i;
    dataset
    {
        dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Posting Date";

            trigger OnPreDataItem()
            var
                tConfirm: TextConst ENU = 'Do you want to duplicate %1 cr.memo(s) to invoice?', FRA = 'Voulez-vous dupliquer %1 avoir(s) en facture ?';
            begin
                if not Confirm(tConfirm, true, Count) then
                    CurrReport.Quit();
                ProgressDialog.Open('');
            end;

            trigger OnAfterGetRecord()
            begin
                if DuplicateToInvoice(SalesCrMemoHeader) then
                    Inserted += 1;
            end;

            trigger OnPostDataItem()
            var
                tDone: TextConst ENU = '%1 Cr.Memo(s) duplicated', FRA = '%1 avoir(s) dupliqué(s)';
            begin
                ProgressDialog.Close();
                Message(tDone, Inserted)
            end;
        }
    }
    var
        ProgressDialog: Dialog;
        Inserted: Integer;

    local procedure DuplicateToInvoice(pSalesCrMemoHeader: Record "Sales Cr.Memo Header"): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceHeader.TransferFields(SalesCrMemoHeader);
        SalesInvoiceHeader."No. Printed" := -1000000000;
        if not SalesInvoiceHeader.Insert(true) then
            Exit(false);
        SalesCrMemoLine.SetRange("Document No.", pSalesCrMemoHeader."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                SalesInvoiceLine.TransferFields(SalesCrMemoLine);
                SalesInvoiceLine."Document No." := SalesInvoiceHeader."No.";
                SalesInvoiceLine.Quantity *= -1;
                SalesInvoiceLine."Line Discount Amount" *= -1;
                SalesInvoiceLine.Amount *= -1;
                SalesInvoiceLine."Amount Including VAT" *= -1;
                SalesInvoiceLine."Inv. Discount Amount" *= -1;
                SalesInvoiceLine."VAT Base Amount" *= -1;
                SalesInvoiceLine."Line Amount" *= -1;
                SalesInvoiceLine."VAT Difference" *= -1;
                SalesInvoiceLine."Pmt. Discount Amount" *= -1;
                SalesInvoiceLine."Quantity (Base)" *= -1;
                SalesInvoiceLine.Insert(true)
            until SalesCrMemoLine.Next() = 0;
        exit(true);
    end;
}
