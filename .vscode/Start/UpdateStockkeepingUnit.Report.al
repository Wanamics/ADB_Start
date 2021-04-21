report 59903 "wan Update Stockkeeping Units"
{
    ProcessingOnly = true;
    Caption = 'Update Stockkeeping Units';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(SKU; "Stockkeeping Unit")
        {
            RequestFilterFields = "Item No.";

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                SKU."Shelf No." := '';
                SKU.Modify(true);
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

