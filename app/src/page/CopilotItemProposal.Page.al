/// <summary>
/// Page Copilot Item Proposal (ID 50101).
/// </summary>
page 50101 "Copilot Item Proposal"
{
    ApplicationArea = All;
    Caption = 'Copilot Item Proposal';
    PageType = ListPart;
    SourceTable = "Copilot Item Proposal";
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            repeater(ItemSubstDetails)
            {
                Caption = ' ';
                ShowCaption = false;

                field(Select; Rec.Select)
                {
                    ToolTip = 'Toggle if you want to add this item to quote';
                    ApplicationArea = All;
                }

                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the item No proposed by Copilot';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the item Description proposed by Copilot';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the Quantity proposed by Copilot';
                    ApplicationArea = All;
                }
                field(Explanation; Rec.Explanation)
                {
                    ToolTip = 'Explanation of why Copilot suggested this line';
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        InStr: InStream;
                        FullExplanation: Text;
                    begin
                        Rec.CalcFields("Full Explanation");
                        Rec."Full Explanation".CreateInStream(InStr);
                        InStr.ReadText(FullExplanation);
                        Message(FullExplanation);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    /// <summary>
    /// Load.
    /// </summary>
    /// <param name="TempCopilotItemProposal">Temporary VAR Record "Copilot Item Proposal".</param>
    procedure Load(var TempCopilotItemProposal: Record "Copilot Item Proposal" temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();

        TempCopilotItemProposal.Reset();
        if TempCopilotItemProposal.FindSet() then
            repeat
                TempCopilotItemProposal.CalcFields("Full Explanation");
                Rec.Copy(TempCopilotItemProposal, false);
                Rec."Full Explanation" := TempCopilotItemProposal."Full Explanation";
                Rec.Insert();
            until TempCopilotItemProposal.Next() = 0;

        CurrPage.Update(false);
    end;

    /// <summary>
    /// SaveSubsForQuote.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    procedure SaveSubsForQuote(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        TempCopilotItemProposal: Record "Copilot Item Proposal" temporary;
        NextLineNo: Integer;
    begin
        //Search Next Line No
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            NextLineNo := SalesLine."Line No." + 10000
        else
            NextLineNo := 10000;

        TempCopilotItemProposal.Copy(Rec, true);
        TempCopilotItemProposal.SetRange(Select, true);

        if TempCopilotItemProposal.FindSet() then
            repeat
                SalesLine.Init();
                SalesLine.Validate("Document Type", SalesHeader."Document Type");
                SalesLine.Validate("Document No.", SalesHeader."No.");
                SalesLine.Validate("Line No.", NextLineNo);
                SalesLine.Insert(true);
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", TempCopilotItemProposal."No.");
                SalesLine.Validate(Quantity, TempCopilotItemProposal.Quantity);
                SalesLine.Validate(GeneratedFromCopilot, true);
                SalesLine.Modify(true);

                //Increment Line No
                NextLineNo += 10000;
            until TempCopilotItemProposal.Next() = 0;
    end;
}
