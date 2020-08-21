global class MockGateway implements blng.PaymentGateWay, blng.PaymentGateWays, blng.PaymentGateWayStatus  {

    private static final String SUCCESS = 'SUCCESS';
    private static final String DECLINE = 'DECLINE';
    private static final String SUCCESSRESPONSECODE = '100';
    private static final String FAILURERESPONSECODE = '200';
    private static final String SUCCESSRESPONSECODEMESSAGE = 'Successful transaction';
    private static final String FAILURERESPONSECODEMESSAGE = 'Transaction failed';
    private static final String GENERATETOKEN = 'GenerateToken';
    private static final String CHARGETRANSACTION = 'ChargeTransaction';
    private static final String REFUND = 'Refund';
    // these card numbers are used to mock failure scenarios
    private static final Set<String> INVALIDCARDDETAILS = new Set<String>
    													 {'4444444444444444',
                                                          '4444222222222222'};
	// these ACH numbers are used to mock failure scenarios                                                              
    private static final Set<String> INVALIDACHDETAILS = new Set<String>
    													 {'4100',
                                                          '4111'};
    Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
    // Amount is used for mocking failure response for saved PMs
    // Inderminate status is for PaymentRun use case
    private static final Map<Double, blng.TransactionResult.GatewayStatusType> INVALIDAMOUNTS =
        new Map<Double, blng.TransactionResult.GatewayStatusType>
    	{5 => blng.TransactionResult.GatewayStatusType.Decline,
         50 => blng.TransactionResult.GatewayStatusType.Decline,
         500 => blng.TransactionResult.GatewayStatusType.Decline,
         10 => blng.TransactionResult.GatewayStatusType.Indeterminate,
         100 => blng.TransactionResult.GatewayStatusType.Indeterminate,
         1000 => blng.TransactionResult.GatewayStatusType.Indeterminate};

    private static MockGateway mockGatewayInstance;
    
    private static MockGateway service() {
        if (NULL == mockGatewayInstance) {
            mockGatewayInstance = new MockGateway();
        }
        return mockGatewayInstance;
    }

    /*
     * Random number used to set Gateway token and Id. 
     */
    private static String getRandomNumber(integer stringLength){
        final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');
    }
    
    /*
     * Returns true if given Card number is in list of invalid card numbers
     */
    private static boolean invalidCC(blng__PaymentMethod__c inputPaymentMethod) {
        return (inputPaymentMethod.blng__PaymentType__c == 'Credit Card' &&
            	INVALIDCARDDETAILS.contains(inputPaymentMethod.blng__CardNumber__c));
    }
    
    /*
     * Returns true if given ACH number is in list of invalid Account numbers
     */
    private static boolean invalidACH(blng__PaymentMethod__c inputPaymentMethod) {
        return (inputPaymentMethod.blng__PaymentType__c == 'ACH' &&
            	INVALIDACHDETAILS.contains(inputPaymentMethod.blng__BankAccountNumber__c));
    }
    
    /*
     * Returns true if given PaymentMethod is invalid CC or invalid ACH
     */
    private static boolean invalidNewPaymentMethod(blng__PaymentMethod__c inputPaymentMethod) {
        return (NULL == inputPaymentMethod.Id) &&
               (invalidCC(inputPaymentMethod) || invalidACH(inputPaymentMethod));
    }

    /*
     * Returns true if given amount is invalid
     */
    private static boolean validAmountforSavedPM(blng.TransactionParameter transactionParameterToProcess) {
        blng__PaymentMethod__c paymentMethod = transactionParameterToProcess.getPaymentMethod();
        String amount = transactionParameterToProcess.getAmount();
        return ((NULL != paymentMethod.Id) &&
                (NULL == amount || INVALIDAMOUNTS.containsKey(Double.valueOf(amount))));
    }
    
    /**
    * @name constructResponse
    * @description Response based on TransactionType and New/Saved PaymentMethod
    * @return Success/Failure response 
    */
    private static Map<String, blng.TransactionResult> constructResponse(String transactionType,
        		Map<String, blng.TransactionParameter> mapOfTransactionParameterById) {
                                                                         
        Map<String, blng.TransactionResult> mapOfTransactionResultById = new Map<String, blng.TransactionResult>();
        for(String idToProcess : mapOfTransactionParameterById.KeySet()) {
            blng.TransactionParameter transactionParameterToProcess;            
            transactionParameterToProcess = mapOfTransactionParameterById.get(idToProcess);

            // For Refund always successful
            if (transactionType != REFUND) {
                boolean invalidReq = false;
                blng.TransactionResult.GatewayStatusType status = null;
                // If new paymentmethod check whether it is invalid CC/BankAccountNumber
                if (invalidNewPaymentMethod(transactionParameterToProcess.getPaymentMethod())) {
                    status = blng.TransactionResult.GatewayStatusType.Decline;
                    invalidReq = true;
              	// Check valid amount only for saved PMs
                } else if (validAmountforSavedPM(transactionParameterToProcess)) {
                    status = INVALIDAMOUNTS.get(Double.valueOf(transactionParameterToProcess.getAmount()));
                    invalidReq = true;
                }

                if (invalidReq) {
                    // It could be either new paymentmethod with invalid CC/BankAccountNumber (or)
                    // saved paymentmethod with invalid amount
                    constructFailureResponse(status, transactionParameterToProcess);
                    continue;
                }
            }
			
            constructSuccessResponse(transactionType, transactionParameterToProcess);
            mapOfTransactionResultById.put(idToProcess, transactionParameterToProcess.transactionResult);
        }
        return mapOfTransactionResultById;
    }
    
    /**
    * @name constructSuccessResponse
    * @description Sets response and gateway status to Success
    * @return NA
    */
    private static void constructSuccessResponse(String transactionType,
                                                 blng.TransactionParameter transactionParameterToProcess) {
        
        transactionParameterToProcess.transactionResult.setResponseToValidate(SUCCESS);
        transactionParameterToProcess.transactionResult.setIsSuccess(true);
        transactionParameterToProcess.transactionResult.setResponseMessage(SUCCESS);
        
        //Populating payment gateway response
        transactionParameterToProcess.transactionResult.setResponseCode(SUCCESSRESPONSECODE);
        transactionParameterToProcess.transactionResult
            .setResponseCodeMessage(SUCCESSRESPONSECODEMESSAGE);
            
        // 16 digit randome number used to set PaymentToken/GatewayId                                             
		String randomNumber = getRandomNumber(8) + getRandomNumber(8);                                                     
        if (GENERATETOKEN == transactionType) {
        	transactionParameterToProcess.transactionResult.setPaymentToken(randomNumber);
        } else {
            transactionParameterToProcess.transactionResult.setGatewayId(randomNumber);
        }
        
        //Populate gateway status
        transactionParameterToProcess.transactionResult.setGatewayStatus(blng.TransactionResult.GatewayStatusType.Success);
    }
    
    /**
    * @name constructFailureResponse
    * @description Sets response and gateway status to Decline/Indeterminate
    * @return NA
    */
    private static void constructFailureResponse(blng.TransactionResult.GatewayStatusType status,
        										 blng.TransactionParameter transactionParameterToProcess) {
        
        transactionParameterToProcess.transactionResult.setResponseToValidate(DECLINE);
        transactionParameterToProcess.transactionResult.setIsSuccess(false);
        transactionParameterToProcess.transactionResult.setResponseMessage(DECLINE);
        
        //Populating payment gateway response
        transactionParameterToProcess.transactionResult.setResponseCode(FAILURERESPONSECODE);
        transactionParameterToProcess.transactionResult
            .setResponseCodeMessage(FAILURERESPONSECODEMESSAGE);
        transactionParameterToProcess.transactionResult.setGatewayId(getRandomNumber(8) + getRandomNumber(8));
        
        //Populate gateway status
        transactionParameterToProcess.transactionResult.setGatewayStatus(status);
    }
    
    global static Map<String, blng.TransactionResult> generateToken(Map<String,
                                                                    blng.TransactionParameter> mapOfTransactionParameterById) {
        return constructResponse(GENERATETOKEN, mapOfTransactionParameterById);
    }
     
    global static Map<String, blng.TransactionResult> chargeTransaction(Map<String,
                                                                        blng.TransactionParameter> mapOfTransactionParameterById) {
    	return constructResponse(CHARGETRANSACTION, mapOfTransactionParameterById);
    }

    global static Map<String, blng.TransactionResult> refundTransaction(Map<String,
                                                                         blng.TransactionParameter> mapOfTransactionParameterById) {
        return constructResponse(REFUND, mapOfTransactionParameterById);
    }
    
    global static Map<String, blng.TransactionResult> authorizeTransaction(Map<String,
                                                                           blng.TransactionParameter> mapOfTransactionParameterById) {
        return null;
    }
    
    global static Map<String, blng.TransactionResult> voidTransaction(Map<String,
                                                                      blng.TransactionParameter> mapOfTransactionParameterById) {
        return null;
    }
    
    global static Map<String, blng.TransactionResult> processPayments(Map<String, blng.TransactionParameter> mapOfTransactionParameterById,
                                                                      blng.PaymentGatewayParameter paymentGatewayParameter) {
        return null;
    }

    global static void populateGatewayStatus(blng.TransactionResult transactionResult) {   
    }                                                               
}
