it("prevents checkout when the customer has no province", () => {


  // Add item
  cy.visit("/products/1");
  cy.contains("Add to Cart").click();


  // Attempt checkout
  cy.visit("/checkout");
  // Log in as customer with no province
  cy.visit("/customers/sign_in");

      cy.get("#customer_email")
      .type("usertester@gmail.com");

    cy.get("#customer_password")
      .type("password");

    cy.get('input[type="submit"][value="Log in"]')
      .click();

  // cy.url()
  //   .should("include", "/customer_profile/edit");

  cy.contains("Please add your province before checkout.")
    .should("be.visible");
});