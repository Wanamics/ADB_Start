report 59928 "_Del. NonStock Without Desc."
{
    ProcessingOnly = true;
    Caption = 'Delete NonStock Items Without Description';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(NonStockItem; "NonStock Item")
        {
            RequestFilterFields = "Entry No.";
            DataItemTableView = where("Description" = const(''));

            trigger OnPreDataItem()

            begin
                if not Confirm('Delete %1 "%2" without Description?', false, Count, TableCaption) then
                    exit;
                StartTime := CurrentDateTime;
                ProgressDialog.OpenCopyCountMax('', Count);
                DeleteAll(true);
                Message('Done in %1', CurrentDateTime - StartTime);
                CurrReport.Quit();
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

