describe("Shopping Cart", () => {
  it("allows a customer to add a product to the cart", () => {
    cy.visit("/products");

    cy.get(".items")
      .first()
      .within(() => {
        cy.contains("View").click();
      });

    cy.contains("Add to Cart").click();

    cy.visit("/cart");

    cy.contains("Cart").should("be.visible");

    cy.get(".cart-item").should("have.length.at.least", 1);

    // Modify quantity
    cy.get("#quantity") .clear().type("2");
    cy.get('input[type="submit"][value="Update"]').click();
    // Verify quantity
    cy.get("#quantity") .should("have.value", "2");
    // Checkout

    cy.get(".checkout-button") .click();

    // Verify checkout page
    cy.contains("Checkout")
      .should("be.visible");

    cy.contains("Subtotal")
      .should("be.visible");
      
      cy.get("#customer_email")
      .type("usertester@gmail.com");

    cy.get("#customer_password")
      .type("password");

    cy.get('input[type="submit"][value="Log in"]')
      .click();

    cy.contains("Order Summary")
      .should("be.visible");
    
    // Place order
    cy.get(".place-order-button")
      .click();

    // Confirmation
    cy.get(".order-information")
      .should("be.visible");

    cy.contains("Order Confirmation")
      .should("be.visible");  

  });
});