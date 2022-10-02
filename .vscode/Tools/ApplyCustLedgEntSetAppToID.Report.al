report 59918 "_Apply CustLedgEnt Set ApptoID"
{
    ApplicationArea = All;
    Caption = 'Apply Cust. Ledger Entries set "Applies-to ID"';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata 21 = m;

    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = where(Open = const(true), "Document Type" = filter(Payment | Refund), "Applies-to ID" = const(''), "External Document No." = filter(<> ''));
            RequestFilterFields = "Customer No.";
            trigger OnAfterGetRecord()
            begin
                "Applies-to ID" := "External Document No.";
                Modify();
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
