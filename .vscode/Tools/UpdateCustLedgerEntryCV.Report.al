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
            RequestFilterFields = "Customer No.";
            trigger OnAfterGetRecord()
            var
                SalesInvoice: Record "Sales Invoice Header";
            begin
                case "Document Type" of
                    "Document Type"::Invoice:
                        if SalesInvoice.Get(CustLedgerEntry."Document No.") then begin
                            CustLedgerEntry."Message to Recipient" := SalesInvoice."Sell-to Contact";
                            CustLedgerEntry.Modify();
                        end;
                    "Document Type"::Payment:
                        begin
                            ;
                            CustLedgerEntry."Message to Recipient" := Description;
                            CustLedgerEntry.Modify();
                        end;
                end;
            end;

            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do-you want to update %1 entries?';
            begin
                if not Confirm(tConfirm, false, Count) then
                    CurrReport.Quit();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }

}
