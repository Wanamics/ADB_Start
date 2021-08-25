report 59909 "Update CustLedgerEntryCV"
{
    ApplicationArea = All;
    Caption = 'Update CustLedgerEntry CV Message';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata 21 = m;

    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = where(Description = filter('Commande CV*'));
            RequestFilterFields = "Customer No.";
            trigger OnAfterGetRecord()
            var
                SalesInvoice: Record "Sales Invoice Header";
            begin
                if SalesInvoice.Get(CustLedgerEntry."Document No.") then begin
                    CustLedgerEntry."Message to Recipient" := SalesInvoice."Sell-to Contact";
                    CustLedgerEntry.Modify();
                end;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
