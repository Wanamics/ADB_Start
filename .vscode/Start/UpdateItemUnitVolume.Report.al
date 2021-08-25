report 59908 "wan Update Item Unit Volume"
{
    ProcessingOnly = true;
    Caption = 'Update Item Unit Volume';
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions = tabledata 113 = m, tabledata 115 = m;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                SalesLine: Record "Sales Line";


            begin
                ProgressDialog.UpdateCopyCount();
                Validate("Replenishment System");
                Modify();
                UpdateSalesLines(Item);
                UpdateSalesInvoiceLines(Item);
                UpdateSalesCrMemoLines(Item);
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

    local procedure UpdateSalesLines(pItem: Record Item)
    var
        Rec: Record "Sales Line";
    begin
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        if Rec.Findset then
            repeat
                Rec."Unit Volume" := pItem."Unit Volume";
                Rec.Modify();
            until Rec.Next() = 0;
    end;

    local procedure UpdateSalesInvoiceLines(pItem: Record Item)
    var
        Rec: Record "Sales Invoice Line";
    begin
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        if Rec.Findset then
            repeat
                Rec."Unit Volume" := pItem."Unit Volume";
                Rec.Modify();
            until Rec.Next() = 0;
    end;

    local procedure UpdateSalesCrMemoLines(pItem: Record Item)
    var
        Rec: Record "Sales Cr.Memo Line";
    begin
        Rec.SetCurrentKey(Type, "No.");
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetRange("No.", pItem."No.");
        if Rec.Findset then
            repeat
                Rec."Unit Volume" := pItem."Unit Volume";
                Rec.Modify();
            until Rec.Next() = 0;
    end;
}

