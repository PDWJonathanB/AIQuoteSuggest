/// <summary>
/// PageExtension SalesQuoteCopilot (ID 50100) extends Record Sales Quote.
/// </summary>
pageextension 50100 SalesQuoteSubformExt extends "Sales Quote Subform"
{
    actions
    {
        addafter(Dimensions)
        {
            action(SuggestItems)
            {
                Caption = 'Suggest Quote with Copilot';
                ToolTip = 'Used to propose items to put in quote from historical order of this customer powered by copilot';
                Image = Sparkle;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    SuggestQuoteWithAI(Rec);
                end;
            }

        }
    }

    local procedure SuggestQuoteWithAI(var SalesLine: Record "Sales Line");
    var
        SalesHeader: Record "Sales Header";
        CopilotQuoteProposal: Page "Copilot Quote Proposal";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        CopilotQuoteProposal.SetSalesHeader(SalesHeader);
        CopilotQuoteProposal.RunModal();
        CurrPage.Update(false);
    end;
}
