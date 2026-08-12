it("does not allow an invalid cart quantity", () => {

  cy.visit("/products/1");

  cy.contains("Add to Cart").click();
  cy.visit("/cart");

 cy.get("#quantity")
    .clear()
    .type("999");

  cy.get('input[type="submit"][value="Update"]').click();


  cy.contains("Only 18 are available.")
    .should("be.visible");
});