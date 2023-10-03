tableextension 50000 GenJournalLine extends "Gen. Journal Line"
{
    fields
    {
        field(50000; ThereforeKey; Code[250])
        {
            Caption = 'ThereforeKey';
            DataClassification = ToBeClassified;
        }
        field(50001; ThereforeKeyInt; Integer)
        {
            Caption = 'ThereforeKey';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnInsert()
    begin
        SetIndivKey();
    end;

    trigger OnModify()
    begin
        SetIndivKey();
    end;

    trigger OnDelete()
    var
        ThereforeDocuments: Record "The-Therefore-Documents";
    begin
        // if you want delete the assigned stored therefore documents
        ThereforeDocuments.Reset();
        ThereforeDocuments.SetRange("Table ID", 81);
        ThereforeDocuments.SetRange("Entry No.", Rec.ThereforeKeyInt);
        //ThereforeDocuments.DeleteAll(false);
    end;

    // The ThereforeKeyInt will be calculated by the highest existing values in the table.
    // If the entry with the highest gets deleted, the next new entry will get this same value again.
    // So the ThereforeKeyInt is only truely unique, if nothing gets deleted.
    // This should not cause any issue, unless references to Therefore documents, are not deleted as well.
    procedure SetIndivKey()
    var
        r: Record "Gen. Journal Line";
    begin
        Rec.ThereforeKey := Rec."Journal Template Name" + Rec."Journal Batch Name" + FORMAT(Rec."Line No.");

        r.Reset();
        if (r.FindLast()) then
            Rec.ThereforeKeyInt := r.ThereforeKeyInt + 1
        else
            Rec.ThereforeKeyInt := 1;
    end;
}
