query 59902 "_Insert Sales Order Release"
{
    Description = 'Select distinct Order No. from Sales Invoice Line';
    QueryType = Normal;

    elements
    {
        dataitem(SalesInvoiceLine; "Sales Invoice Line")
        {
            DataItemTableFilter = "Order No." = filter('<>'''''), "Quantity" = filter('<>0');

            column(OrderNo; "Order No.")
            {
            }
            column(Count)
            {
                Method = Count;
            }
        }
    }
}
