Configure the Test Payment Gateway Adapter for Salesforce Billing [Github Readme]

We've made it easier for you to test/demonstrate Salesforce Billing Payment capabilities without connecting to actual gateway endpoint. Previously, demonstrating or testing Salesforce Billing payment features required a connection to a payment gateway. However, gateway connections sometimes failed if you didn't have access to a fully-implemented payment gateway adapter. You can now configure a test gateway adapter that passes payment information to a test payment gateway built only for demonstrations. 

The test gateway sends a failure, success, or indeterminate response based on predefined input values, so you can quickly demonstrate your integration's response processes. This way, you can quickly test your integrations or provide demonstrations for customers without having to set up connections.

*Getting Started*
The test gateway adapter supports all of the Salesforce Billing payment processing flows:

1. Payment Center
2. Payment Run
3. Force.com (http://force.com/) Payment Site
4. Hosted Card Payments Lightning Component


*Setting Up the Test Gateway in Salesforce*
The Test Gateway requires Salesforce CPQ and Salesforce Billing.

1. Create the Apex classes which are in src/classes into your org.
    1. Download the Apex class code from src/classes/ folder.
    2. In Salesforce, from Setup, enter *Apex Classes*, and then select *Apex Classes*.
    3. Click New, then copy and paste your class. Repeat for each class in the Test Gateway github folder.
    4. Open the MockGatewayTest Apex class detail page, and then click *Run Test*. Salesforce will run a test to ensure that your class has been configured successfully.
2. From Setup, enter *Custom Settings*, and then select *Custom Settings*.
3. Select *Payment Gateway Config*, and then select *Manage*.
4. Click *New*, then enter *MockGateway* for the gateway class name. You can set the name to any value of your choosing. Save your changes.
5. Add the *Name *of your new payment gateway config custom setting as a new picklist value on the payment gateway object’s Gateway Type field.
    1. From Setup, enter *Object Manager*, select *Payment Gateway*, select *Fields & Relationships*, and then select *Gateway Type*.
    2. Click *View Gateway Type Value Set*.
    3. Enter the *Name* of of your new payment gateway config custom setting, then save your changes.
6. Create a payment gateway record with a Gateway Type field set to your new test gateway.


*Using the Test Gateway Adapter*
*Testing w/ New Credit Card and ACH Values*
We’ve configured the test gateway adapter to provide failure responses for specific credit card and ACH values. This way, you can quickly demonstrate how your integration processes failure responses.

The test gateway will send a Failure response response after receiving either of the following credit card numbers.

1. 4444444444444444
2. 4444222222222222

The test gateway will send a Failure response response after receiving either of the following ACH numbers.

1. 4100
2. 4111

The test gateway will send a Success response for all other credit card and ACH numbers.

*Testing with Saved Payment Methods*
We’ve configured the test gateway adapter to provide failure responses for specific amounts when making payments using a saved payment method. This way, you can quickly demonstrate how your integration processes failure responses.

The test gateway will send a Decline response for payment request with the following Amount values.

1. $5
2. $50
3. $500

The test gateway will send an Indeterminate response for payment request with the following Amount values.

1. $10
2. $100
3. $1000

The test gateway will send a Success response for all other payment amounts.
