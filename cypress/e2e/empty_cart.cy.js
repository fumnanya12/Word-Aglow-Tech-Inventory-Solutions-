it("does not allow checkout with an empty cart", () => {

  cy.visit("/cart");
   
  //     cy.get("#customer_email")
  //     .type("usertester@gmail.com");

  //   cy.get("#customer_password")
  //     .type("password");

  //   cy.get('input[type="submit"][value="Log in"]')
  //     .click();

  // cy.url()
  //   .should("include", "/cart");

  cy.contains("Your cart is currently empty.")
    .should("be.visible");
});