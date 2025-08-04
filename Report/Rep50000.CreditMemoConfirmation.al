report 50000 "Credit Memo Confirmation"
{
    Caption = 'Credit Memo Confirmation';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = 'ReportLayout/Report50000.docx';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            RequestFilterFields = "Document Type", "No.";

            column(DocumentType; "Document Type") { }
            column(No; "No.") { }
            column(SellToCustomerNo; "Sell-to Customer No.") { }
            column(SellToCustomerName; "Sell-to Customer Name") { }
        }
    }
}
