report 59929 "_Update Item Trigger Webhook"
{
    // Attention : la "Feuille création emplacement" doit être validée après ce traitement le cas échant

    ProcessingOnly = true;
    Caption = 'Update Item to Trigger Webhook';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", Type, "Replenishment System";

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                if "Unit Price" <> 0 then // Trigger webhook to update PrestaShop
                    Item.Modify(true);

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

}