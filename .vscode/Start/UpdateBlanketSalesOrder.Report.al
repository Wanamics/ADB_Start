report 59904 "wan Update Blanket Sales order"
{
    ProcessingOnly = true;
    Caption = 'Update Blanket Sales Order';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = Where("Document Type" = Const("Blanket Order"));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                SuspendStatusCheck(true);
                SetHideValidationDialog(true);
                /*
                validate("Prices Including VAT", true);
                modify(true);
                */
                "Responsibility Center" := 'ADB';
                Modify(false);
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

