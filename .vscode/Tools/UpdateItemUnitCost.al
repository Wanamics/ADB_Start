report 59911 "Update Item Unit Cost"
{
    ApplicationArea = All;
    Caption = 'Update Item Unit Cost';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata 113 = m, tabledata 115 = m;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Unit Cost", "Standard Cost", Type, "Replenishment System";
            trigger OnPreDataItem()
            var
                tConfirm: Label 'Do-you want to update "Unit Cost" on %1 Item(s) then update "Sales Line", "Sales Invoice Line" and "Sales Cr.Memo Lines"?';
            begin
                SetLoadFields("No.", "Unit Cost", "Standard Cost");
                if not Confirm(tConfirm, false, count) then
                    CurrReport.Quit();
                ProgressDialog.OpenCopyCountMax('', Count);
            end;

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                "Unit Cost" := "Standard Cost";
                Modify;
                UpdateSalesLines(Item);
                UpdateSalesInvoiceLines(Item);
                UpdateSalesCrMemoLines(Item);
            end;
        }
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
        if Rec.FindSet() then
            repeat
                Rec.Testfield("Currency Code", '');
                Rec."Unit Cost" := pItem."Unit Cost";
                Rec."Unit Cost (LCY)" := pItem."Unit Cost";
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
        if Rec.FindSet() then
            repeat
                //Rec.Testfield("Currency Code", '');
                Rec."Unit Cost" := pItem."Unit Cost";
                Rec."Unit Cost (LCY)" := pItem."Unit Cost";
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
        if Rec.FindSet() then
            repeat
                //Rec.Testfield("Currency Code", '');
                Rec."Unit Cost" := pItem."Unit Cost";
                Rec."Unit Cost (LCY)" := pItem."Unit Cost";
                Rec.Modify();
            until Rec.Next() = 0;
    end;
}
