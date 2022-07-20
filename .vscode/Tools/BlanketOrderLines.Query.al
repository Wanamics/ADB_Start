query 59901 "wan Blanket Order Lines"
{
    APIGroup = 'BlanketOrders';
    APIPublisher = 'Wanamics';
    APIVersion = 'v1.0';
    EntityName = 'blanketOrderLine';
    EntitySetName = 'blanketOrderLines';
    QueryType = API;

    elements
    {
        dataitem(salesHeader; "Sales Header")
        {
            column(no; "No.")
            {
            }
            column(sellToCustomerNo; "Sell-to Customer No.")
            {
            }
            column(sellToCustomerName; "Sell-to Customer Name")
            {
            }
            column(campaignNo; "Campaign No.")
            {
            }
            dataitem(salesLine; "Sales Line")
            {
                DataItemLink = "Document Type" = salesHeader."Document Type", "Document No." = salesHeader."No.";
                column(type; Type) { }
                column(number; "No.") { }
                column(description; Description) { }
                column(unitPrice; "Unit Price") { }
                column(completelyShipped; "Completely Shipped") { }
            }
        }
    }
}
