pageextension 50001 "General-JournalExt" extends "General Journal" // Page 39
{
    layout
    {
        addfirst(factboxes)
        {
            part("The-Drag-Drop-Documents"; "The-Drag-Drop-Documents-ListPa")
            {
                Caption = 'Drag & Drop Documents';
                ApplicationArea = All;
                SubPageLink =
                    "Entry No." = Field(ThereforeKeyInt),
                    "Table ID" = const(81); // Insert Table ID here
                Visible = bShow;
            }
        }
    }

    var
        bShow: Boolean;
        cuThereforeFunctions: Codeunit "The-Therefore-Functions";
        cuWebServiceFunctions: Codeunit "The-Webservice-Functions";

    trigger OnOpenPage()
    begin
        bShow := cuThereforeFunctions.DragDrop_MappingAvailable(cuThereforeFunctions.GetTableID(Rec.TableName), 0);
    end;
}
