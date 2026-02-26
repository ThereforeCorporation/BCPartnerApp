pageextension 50004 "Partner The-Therefore-Setup" extends "The-Therefore-Setup-Card" // page 52101153
{
    actions
    {
        addlast(Setup)
        {
            action(Test_BlobArchive)
            {
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;
                Caption = 'Test Blob Archive';
                ApplicationArea = All;

                trigger OnAction()
                var
                    cuTempBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                    ThePostFunctions: codeunit "The-Post-Functions";
                begin
                    cuTempBlob.CreateOutStream(OutStr);
                    if (Report.SaveAs(Report::"Chart of Accounts", '', ReportFormat::Pdf, OutStr)) then begin
                        ThePostFunctions.AddDocumentToQueueWithBlob(
                            3,          // Mapping ID -> "Posted Invoice" Mapping
                            '103198',   // PK: Document No
                            0D,         // PK: Document Date,
                            0,          // PK: Entry No,
                            0,          // PK: Document Type,
                            '',         // Identification No,
                            '',         // Business Case ID,
                            cuTempBlob,
                            'Invoice_103198.pdf'
                        );
                        Message('Blob archived');
                    end else
                        Error('Report cannot be created.');
                end;
            }
        }
    }
}
