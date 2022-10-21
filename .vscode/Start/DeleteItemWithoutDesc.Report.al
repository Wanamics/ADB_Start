report 59927 "wan Delete Item Without Desc."
{
    ProcessingOnly = true;
    Caption = 'Delete Item Without Description';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            DataItemTableView = where("Description" = const(''));

            trigger OnPreDataItem()

            begin
                if not Confirm('Delete %1 "%2" without Description?', false, Count, TableCaption) then
                    exit;
                StartTime := CurrentDateTime;
                ProgressDialog.OpenCopyCountMax('', Count);
            end;

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                Delete(true);
            end;

            trigger OnPostDataItem()
            begin
                if StartTime <> 0DT then
                    Message('Done in %1', CurrentDateTime - StartTime);
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
        StartTime: DateTime;
}

