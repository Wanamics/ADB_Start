report 59916 "wan Set Dim2"
{
    ProcessingOnly = true;
    Caption = 'Set Dim2';
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions =
        tabledata "Sales Invoice Header" = m,
        tabledata "Sales Invoice Line" = m,
        tabledata "Sales Cr.Memo Header" = m,
        tabledata "Sales Cr.Memo Line" = m;

    dataset
    {
        /*
        dataitem(Customer; Customer)
        {
            DataItemTableView =;
            trigger OnPreDataItem()
            begin
                if SellToCustomer."No." <> '' then
                    Setrange("No.", SellToCustomer."No.");
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            var
                xDim2: Code[20];
            begin
                ProgressDialog.UpdateCopyCount();
                xDim2 := "Global Dimension 2 Code";
                case true of
                    "No." = '999999':
                        Validate("Global Dimension 2 Code", 'I');
                    "Combine Shipments":
                        Validate("Global Dimension 2 Code", 'G');
                    //CopyStr("Shipment Method Code", 1, 3) = 'ETB':
                    //    Validate("Global Dimension 2 Code", 'CF');
                    else
                        Validate("Global Dimension 2 Code", 'CO');
                end;
                if "Global Dimension 2 Code" <> xDim2 then
                    Modify(false);
            end;

            trigger OnPostDataItem()
            begin
                Clear(ProgressDialog);
            end;
        }
        dataitem(SHR; "wan Sales Header Release")
        {
            DataItemTableView = sorting();

            trigger OnPreDataItem()
            begin
                if SellToCustomer."No." <> '' then
                    Setrange("Sell-to Customer No.", SellToCustomer."No.");
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                if Dim2Updated("Sell-to Customer No.", "Shortcut Dimension 2 Code", "Shipment Method Code") then
                    Modify(false);
            end;

            trigger OnPostDataItem()
            begin
                Clear(ProgressDialog);
            end;
        }
        */
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            DataItemTableView = sorting("Sell-to Customer No.");

            trigger OnPreDataItem()
            begin
                if SellToCustomer."No." <> '' then
                    Setrange("Sell-to Customer No.", SellToCustomer."No.");
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            var
                SalesInvoiceLine: Record "Sales Invoice Line";
            begin
                ProgressDialog.UpdateCopyCount();
                if Dim2Updated("Sell-to Customer No.", "Shortcut Dimension 2 Code", "Shipment Method Code") then
                    Modify(false);
                SalesInvoiceLine.SetRange("Document No.", "No.");
                SalesInvoiceLine.SetFilter("Shortcut Dimension 2 Code", '<>%1', "Shortcut Dimension 2 Code");
                SalesInvoiceLine.ModifyAll("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code", false);
            end;

            trigger OnPostDataItem()
            begin
                Clear(ProgressDialog);
            end;
        }
        dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
        {
            DataItemTableView = sorting("Sell-to Customer No.");

            trigger OnPreDataItem()
            begin
                if SellToCustomer."No." <> '' then
                    Setrange("Sell-to Customer No.", SellToCustomer."No.");
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            var
                SalesCrMemoLine: Record "Sales Cr.Memo Line";
            begin
                ProgressDialog.UpdateCopyCount();
                if Dim2Updated("Sell-to Customer No.", "Shortcut Dimension 2 Code", "Shipment Method Code") then
                    Modify(false);
                SalesCrMemoLine.SetRange("Document No.", "No.");
                SalesCrMemoLine.SetFilter("Shortcut Dimension 2 Code", '<>%1', "Shortcut Dimension 2 Code");
                SalesCrMemoLine.ModifyAll("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code", false);
            end;


            trigger OnPostDataItem()
            begin
                Clear(ProgressDialog);
            end;
        }

        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = sorting("Sell-to Customer No.");

            trigger OnPreDataItem()
            begin
                if SellToCustomer."No." <> '' then
                    Setrange("Sell-to Customer No.", SellToCustomer."No.");
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            var
                SalesLine: Record "Sales Line";
            begin
                ProgressDialog.UpdateCopyCount();
                if Dim2Updated("Sell-to Customer No.", "Shortcut Dimension 2 Code", "Shipment Method Code") then
                    Modify(false);
                SalesLine.SetRange("Document Type", "Document Type");
                SalesLine.SetRange("Document No.", "No.");
                SalesLine.SetFilter("Shortcut Dimension 2 Code", '<>%1', "Shortcut Dimension 2 Code");
                SalesLine.ModifyAll("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code", false);
            end;

            trigger OnPostDataItem()
            begin
                Clear(ProgressDialog);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                field(CustomerNo; SellToCustomer."No.")
                {
                    ApplicationArea = All;
                    TableRelation = Customer;
                }
            }
        }
    }

    var
        ProgressDialog: Codeunit "Progress Dialog";
        GLSetup: Record "General Ledger Setup";
        SellToCustomer: Record Customer;

    trigger OnPreReport()
    begin
        if not Confirm('Set Dim2 on Customers and Sales Documents ?') then
            CurrReport.Quit();
        GLSetup.Get();
        GLSetup.TestField("Global Dimension 2 Code");
    end;

    local procedure Dim2Updated(pCustomerNo: code[20]; var pDim2: Code[20]; pShipmentMethodCode: Code[20]): Boolean
    var
        DefaultDim: Record "Default Dimension";
        xDim2: Code[20];
    begin
        xDim2 := pDim2;
        case true of
            DefaultDim.Get(Database::Customer, pCustomerNo, GLSetup."Global Dimension 2 Code") and
            (DefaultDim."Dimension Value Code" in ['I', 'G']):
                pDim2 := DefaultDim."Dimension Value Code";
            CopyStr(pShipmentMethodCode, 1, 3) = 'ETB':
                pDim2 := 'CF';
            else
                pDim2 := 'CO';
        end;
        exit(pDim2 <> xDim2);
    end;
}
