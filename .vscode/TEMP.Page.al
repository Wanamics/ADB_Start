page 59999 "TEMP Capitalize"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Source; Source)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Target := Source;
                        Capitalize(Target);
                    end;

                }
                field(Target; Target)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
    }

    var
        Source, Target : Text;

    local procedure Capitalize(var pText: Text)
    var
        i: Integer;
        StringList: List of [Text];
    begin
        pText := pText.Trim();
        pText := pText.Replace('  ', ' ');
        StringList := pText.Split(' ', '|');
        pText := StringList.Get(1) + '|';
        for i := 2 to StringList.Count() do begin
            if (i > 2) and not pText.EndsWith(' ') and not pText.EndsWith('|') and not pText.EndsWith('/') then
                pText += ' ';
            pText += Caps(StringList.Get(i).Trim);
        end;
    end;

    local procedure Caps(pText: Text): Text
    var
        i: Integer;
    begin
        if strlen(pText) <= 1 then
            exit(pText);
        pText := UpperCase(CopyStr(pText, 1, 1)) + LowerCase(CopyStr(pText, 2));
        for i := 2 to StrLen(pText) - 1 do begin
            //if pText[i] in ['-','.',' ','_'] then
            //    pText[i] := '-';
            if pText[i - 1] = '-' then
                pText := CopyStr(pText, 1, i - 1) + UpperCase(CopyStr(pText, i, 1)) + CopyStr(pText, i + 1);
        end;
        exit(pText);
    end;
}