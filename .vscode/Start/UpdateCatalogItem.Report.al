report 59902 "wan Update Catalog Item"
{
    ProcessingOnly = true;
    Caption = 'Update Catalog Item';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(NonstockItem; "Nonstock Item")
        {
            RequestFilterFields = "Entry No.";

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                NonstockItem."Net Weight" *= 1000;
                NonstockItem.Modify(false);
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

