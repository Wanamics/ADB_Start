report 59906 "wan Update Sales order"
{
    ProcessingOnly = true;
    Caption = 'Update Sales Order';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = Where("Document Type" = Const("Order"));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                xRec: Record "Sales Header";
            begin
                ProgressDialog.UpdateCopyCount();
                SuspendStatusCheck(true);
                SetHideValidationDialog(true);
                xRec := SalesHeader;
                Capitalize(SalesHeader."Ship-to Contact");
                if SalesHeader."Ship-to Contact" <> xRec."Ship-to Contact" then
                    modify(true);
            end;

            trigger OnPreDataItem()
            begin
                if not Confirm('Update %1 %2 OK?', false, Count, TableCaption) then
                    exit;
                ProgressDialog.OpenCopyCountMax('', Count);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ProgressDialog: Codeunit "Progress Dialog";

    local procedure Capitalize(var pText: Text)
    var
        i: Integer;
        StringList: List of [Text];
    begin
        pText := pText.Trim();
        pText := pText.Replace('  ', ' ');
        StringList := pText.Split(' ');
        pText := '';
        for i := 1 to StringList.Count() do begin
            if (i > 1) and not pText.EndsWith(' ') and not pText.EndsWith('|') and not pText.EndsWith('/') then
                pText += ' ';
            pText += Caps(StringList.Get(i).Trim);
            //StringList.Set(i, StringList.Get(i).Trim);
            /*
            if StringList.Get(i) <> '' then
                pText += StringList.Get(i).Substring(1, 1).ToUpper;
            if strlen(StringList.Get(i)) > 1 then
                pText += StringList.Get(i).Substring(2).ToLower;
            */
        end;
    end;

    local procedure Caps(pText: Text): Text
    var
        i: Integer;
    begin
        if strlen(pText) <= 1 then
            exit(pText);
        pText := UpperCase(CopyStr(pText, 1, 1)) + LowerCase(CopyStr(pText, 2));
        for i := 2 to StrLen(pText) - 1 do begin
            //if pText[i] in ['-','.',' ','_'] then
            //    pText[i] := '-';
            if pText[i - 1] = '-' then
                pText := CopyStr(pText, 1, i - 1) + UpperCase(CopyStr(pText, i, 1)) + CopyStr(pText, i + 1);
        end;
        exit(pText);
    end;

}

