/// <summary>
/// PageExtension CustomerCardExt (ID 50101) extends Record Customer Card.
/// </summary>
pageextension 50101 CustomerCardExt extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field(HistoricalDataStartDate; Rec.HistoricalDataStartDate)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the starting date that copilot will have access to for its historical data (blank value = all historical data)';
            }
        }
    }

    actions
    {
        addafter(Dimensions)
        {
            action(SuggestItems)
            {
                Caption = 'Suggest Quote with Copilot';
                ToolTip = 'Used to create Quote and propose items to put in quote from historical order of this customer powered by copilot';
                Image = Sparkle;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    SuggestQuoteWithAI(Rec);
                end;
            }

        }
    }

    local procedure SuggestQuoteWithAI(var Customer: Record Customer);
    var
        SalesHeader: Record "Sales Header";
        CopilotQuoteProposal: Page "Copilot Quote Proposal";
        SalesQuote: Page "Sales Quote";
    begin
        //Create Sales Header (Quote)
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.Validate("Document Date", Today);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Insert(true);

        Commit();

        CopilotQuoteProposal.SetSalesHeader(SalesHeader);
        CopilotQuoteProposal.RunModal();

        //Test if creation is done
        SalesHeader.CalcFields(ContainsCopilotGeneratedLines);
        if SalesHeader.ContainsCopilotGeneratedLines then begin
            SalesHeader.SetRecFilter();
            SalesQuote.SetTableView(SalesHeader);
            SalesQuote.Run();
        end else
            SalesHeader.Delete();
    end;
}
