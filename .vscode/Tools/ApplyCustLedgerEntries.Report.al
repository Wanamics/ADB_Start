report 59917 "_Apply Cust. Ledger Entries"
{
    ApplicationArea = All;
    Caption = 'Apply Cust. Ledger Entries';
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            dataitem(Integer; Integer)
            {
                DataItemTableView = sorting(Number);
                trigger OnPreDataItem()
                begin
                    ApplyCustLedgerEntryQuery.SetRange(CustomerNo, Customer."No.");
                    ApplyCustLedgerEntryQuery.Open();
                end;

                trigger OnAfterGetRecord()
                begin
                    if not ApplyCustLedgerEntryQuery.Read() then
                        CurrReport.Break()
                    else
                        if ApplyCustLedgerEntryQuery.RemainingAmount = 0 then
                            Apply(ApplyCustLedgerEntryQuery);
                end;
            }
            trigger OnPreDataItem()
            begin
                if not Confirm('Do you want to apply %1 customer(s) based on "Applies-to Id" ?', false, Count()) then
                    CurrReport.Quit();
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    var
        ApplyCustLedgerEntryQuery: Query _ApplyCustLedgerEntries;
        GLSetup: Record "General Ledger Setup";
        ProgressDialog: Codeunit "Progress Dialog";

    trigger OnInitReport()
    var
        UserSetup: Record "User Setup";
    begin
        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GLSetup.TestField("Apply Jnl. Template Name");
            GLSetup.TestField("Apply Jnl. Batch Name");
        end;
        if UserSetup.Get(UserId) and
            (UserSetup."Allow Posting From" < GLSetup."Allow Posting From") and
            (UserSetup."Allow Posting From" <> 0D) then
            GLSetup."Allow Posting From" := UserSetup."Allow Posting From";
    end;

    local procedure Apply(pQuery: Query _ApplyCustLedgerEntries)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        ApplicationDate: Date;
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.", "Applies-to ID");
        CustLedgerEntry.SetRange("Customer No.", pQuery.CustomerNo);
        CustLedgerEntry.SetRange("Applies-to ID", pQuery.AppliestoID);
        CustLedgerEntry.SetRange(Open, True);
        CustLedgerEntry.SetRange("Currency Code", pQuery.CurrencyCode);
        CustLedgerEntry.SetRange("Customer Posting Group", pQuery.CustomerPostingGroup);

        if CustLedgerEntry.FindSet() then
            repeat
                if CustLedgerEntry."Amount to Apply" = 0 then begin
                    CustLedgerEntry.CalcFields("Remaining Amount");
                    CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
                end else
                    CustLedgerEntry."Amount to Apply" := 0;
                CustLedgerEntry."Accepted Payment Tolerance" := 0;
                CustLedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
                CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", CustLedgerEntry);
                if CustLedgerEntry."Posting Date" > ApplicationDate then
                    ApplicationDate := CustLedgerEntry."Posting Date";
            until CustLedgerEntry.Next() = 0;

        ApplyUnapplyParameters.CopyFromCustLedgEntry(CustLedgerEntry);
        ApplyUnapplyParameters."Posting Date" := ApplicationDate;
        if GLSetup."Journal Templ. Name Mandatory" then begin
            ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
        end;
        if ApplyUnapplyParameters."Posting Date" < GLSetup."Allow Posting From" then
            ApplyUnapplyParameters."Posting Date" := GLSetup."Allow Posting From";
        CustEntryApplyPostedEntries.Apply(CustLedgerEntry, ApplyUnapplyParameters);
    end;
}