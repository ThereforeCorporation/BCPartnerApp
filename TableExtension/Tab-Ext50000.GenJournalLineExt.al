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
