//#Statistiques
report 59910 "Sales Cr.Memos to Inv. Union"
{
    ApplicationArea = All;
    Caption = 'Sales Cr.Memos to Inv. Union';
    UsageCategory = Administration;
    ProcessingOnly = true;
    dataset
    {
        dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Posting Date";

            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do you want to duplicate %1 "Sales Cr.Memo" to "Sales Invoice"?';
            begin
                if not Confirm(tConfirm, true, Count) then
                    CurrReport.Quit();
                ProgressDialog.Open('');
            end;

            trigger OnAfterGetRecord()
            var
                SalesCrMemoPosting: Codeunit "wan Sales Cr.Memo Posting";
            begin
                if SalesCrMemoPosting.CopyCrMemoToInvoice(SalesCrMemoHeader) then
                    Inserted += 1;
            end;

            trigger OnPostDataItem()
            var
                tDone: Label '%1 "Sales Cr.Memo" duplicated to "Sales Invoice" ';
            begin
                ProgressDialog.Close();
                Message(tDone, Inserted)
            end;
        }
    }
    var
        ProgressDialog: Dialog;
        Inserted: Integer;
}
