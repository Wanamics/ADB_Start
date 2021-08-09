report 59930 "Monetico Switch Description"
{
    Caption = 'Monetico Switch Description';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItemName; "Cust. Ledger entry")
        {
            RequestFilterFields = "Customer No.";
            DataItemTableView = where("Document Type" = filter('Payment'));
            trigger OnPreDataItem()
            begin
                if not confirm('Proceed %1 record(s)?', false, Count) then
                    CurrReport.Quit();
            end;

            trigger OnAfterGetRecord()
            begin
                Description := SwitchDescription(Description);
                Modify();
            end;
        }
    }
    local procedure SwitchDescription(pDescription: Text): Text;
    var
        lPos: Integer;
    begin
        lPos := StrPos(pDescription, '] ');
        if lPos = 0 then
            exit(pDescription)
        else
            exit(copystr(pDescription, lPos + 2) + ' ' + CopyStr(pDescription, 1, lPos));
    end;

}