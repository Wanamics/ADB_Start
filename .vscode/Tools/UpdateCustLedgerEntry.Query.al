query 59900 UpdateCustLedgerEntry
{
    Caption = 'UpdateCustLedgerEntry';
    QueryType = Normal;


    elements
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            column(CustomerNo; "Customer No.")
            {
            }
            column(MessagetoRecipient; "Message to Recipient")
            {
            }
            column(Open; Open)
            {

            }
            column(Amount; Amount)
            {
                Method = Sum;
            }
            column(RemainingAmount; "Remaining Amount")
            {
                Method = Sum;
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
