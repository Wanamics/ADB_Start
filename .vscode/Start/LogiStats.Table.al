table 59900 "wan LogiStats Buffer"
{
    Caption = 'LogiStats';
    DataClassification = ToBeClassified;
    TableType = Temporary;


    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Customer No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Order Type"; Code[10])
        {
            Caption = 'Order Type';
            DataClassification = ToBeClassified;
            TableRelation = "Shipment Method";
        }
        field(4; Sales; Decimal)
        {
            Caption = 'Sales';
            DataClassification = ToBeClassified;
        }
        field(5; Profit; Decimal)
        {
            Caption = 'Profit';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Customer No.", "Posting Date")
        {
            Clustered = true;
        }
    }

}
