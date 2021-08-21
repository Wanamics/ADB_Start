//#Statistiques
report 59912 "Delete Cr.Memos to Inv. Union"
{
    ApplicationArea = All;
    Caption = 'Delete Sales Cr.Memos to Inv. Union';
    UsageCategory = Administration;
    ProcessingOnly = true;
    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {

            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do you want to delete %1 "Cr. Memos" in "Sales Invoices"?';
            begin
                SetFilter("No.", 'AV*');
                if not Confirm(tConfirm, true, Count) then
                    CurrReport.Quit();
                DeleteAll(true);
                Message('Done');
            end;

        }
    }
    var
}
