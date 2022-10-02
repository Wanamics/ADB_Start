report 59907 "Update CustLedgerEntry@"
{
    ApplicationArea = All;
    Caption = 'Update CustLedgerEntry @ Message';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata 21 = m;

    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = where(Description = filter('*@*'));
            RequestFilterFields = "Customer No.";
            trigger OnAfterGetRecord()
            var
                First, Last : integer;
            begin
                First := strpos(Description, '@');
                Last := First;
                while (First > 1) and (Description[First] <> ' ') do
                    First -= 1;
                if Description[First] = ' ' then
                    First += 1;
                While (Last < strlen(Description)) and (Description[Last] <> ' ') do
                    Last += 1;
                if Description[Last] = ' ' then
                    Last -= 1;
                "Message to Recipient" := copystr(Description, First, Last);
                if ("Document Type" in ["Document Type"::Payment, "Document Type"::Refund]) and ("Applies-to ID" = '') and ("External Document No." <> '') then
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
