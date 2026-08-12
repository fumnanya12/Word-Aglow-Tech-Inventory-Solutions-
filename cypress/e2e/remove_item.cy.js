it("allows a customer to remove an item from the cart", () => {

  cy.visit("/products/1");

    cy.contains("Add to Cart").click();


  cy.visit("/cart");

  cy.get(".cart-item")
    .should("exist");

  cy.get(".remove-cart-item-button")
    .click();

  cy.get(".cart-item")
    .should("not.exist");

  cy.contains("Your cart is currently empty.")
    .should("be.visible");
});