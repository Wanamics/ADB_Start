page 59903 "wan LogiStats"
{

    ApplicationArea = All;
    Caption = 'LogiStats';
    PageType = List;
    SourceTable = "wan LogiStats Buffer";
    SourceTableTemporary = true;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Order Type"; Rec."Order Type")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Profit; Rec.Profit)
                {
                    ApplicationArea = All;
                }
                field(Sales; Rec.Sales)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {

            action(Split)
            {
                ApplicationArea = All;
                Caption = 'Split Excel to Excel';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    codeunit.run(Codeunit::"wan LogiStats Excel", Rec);
                end;
            }
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import to Posted Invoices';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    LogistatsImport: Codeunit "wan LogiStats Import";
                begin
                    LogistatsImport.Import();
                end;
            }
        }
    }
}
