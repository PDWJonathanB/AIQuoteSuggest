/// <summary>
/// PageExtension CustomerListExt (ID 50104) extends Record Customer List.
/// </summary>
pageextension 50104 CustomerListExt extends "Customer List"
{
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
